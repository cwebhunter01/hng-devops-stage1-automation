#!/bin/bash

# === HNG Stage 1 Deployment Script ===

set -e
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="deploy_$TIMESTAMP.log"
exec > >(tee -i "$LOG_FILE") 2>&1

echo "======================================================"
echo " Starting Automated Deployment Script for HNG Stage 1"
echo "======================================================"
echo " Log file: $LOG_FILE"
echo ""

# Collect user inputs
read -p "Enter GitHub repository URL: " REPO_URL
read -p "Enter your Personal Access Token (PAT): " PAT
read -p "Enter branch name (default: main): " BRANCH
read -p "Enter SSH username for remote server: " SSH_USER
read -p "Enter Server IP address: " SERVER_IP
read -p "Enter path to your SSH private key (e.g., ~/.ssh/id_rsa): " SSH_KEY
read -p "Enter application internal port (e.g., 8080): " APP_PORT

BRANCH=${BRANCH:-main}

# Validate input
if [[ -z "$REPO_URL" || -z "$PAT" || -z "$SSH_USER" || -z "$SERVER_IP" || -z "$SSH_KEY" || -z "$APP_PORT" ]]; then
  echo " Error: All fields are required!"
  exit 1
fi

echo ""
echo " Parameters collected successfully!"
echo "Repository: $REPO_URL"
echo "Branch: $BRANCH"
echo "Server: $SSH_USER@$SERVER_IP"
echo "Port: $APP_PORT"
echo ""

# Cleanup old logs: keep only last 5
ls -1tr deploy_*.log 2>/dev/null | head -n -5 | xargs -r rm -f --

# Cleanup old local repo folder
if [ -d "repo" ]; then
    echo "Cleaning up old 'repo' folder..."
    rm -rf repo
fi

# Clone latest repo
echo " Cloning repository..."
git clone --branch "$BRANCH" "https://$PAT@github.com/${REPO_URL#https://github.com/}" repo
cd repo || exit 1

# Check for Dockerfile or docker-compose.yml
if [ ! -f Dockerfile ] && [ ! -f docker-compose.yml ]; then
  echo " Error: No Dockerfile or docker-compose.yml found in the repository!"
  exit 1
else
  echo " Repository verified — Dockerfile found."
fi

# SSH deployment
echo ""
echo "🔹 Connecting to remote server and deploying application..."
ssh -i "$SSH_KEY" "$SSH_USER@$SERVER_IP" << EOF
set -e

APP_DIR="/var/www/hng-app"
CONTAINER_NAME="hng-container"
IMAGE_NAME="hng-app"

# Update system and install dependencies
sudo apt update -y
sudo apt install -y docker.io nginx git curl
sudo systemctl enable docker
sudo systemctl start docker

# Stop and remove old container
if sudo docker ps -a --format '{{.Names}}' | grep -Eq "^$CONTAINER_NAME\$"; then
    echo "Stopping and removing old container..."
    sudo docker stop \$CONTAINER_NAME || true
    sudo docker rm \$CONTAINER_NAME || true
fi

# Remove old Docker image
if sudo docker images -q \$IMAGE_NAME > /dev/null 2>&1; then
    echo "Removing old Docker images..."
    sudo docker rmi -f \$IMAGE_NAME || true
fi

# Remove old Docker volumes related to app
echo "Cleaning up old Docker volumes..."
sudo docker volume ls -q | grep "hng" | xargs -r sudo docker volume rm || true

# Prepare app directory
sudo rm -rf \$APP_DIR
sudo mkdir -p \$APP_DIR
cd \$APP_DIR

# Clone latest repo
sudo git clone -b $BRANCH $REPO_URL .

# Build Docker image
sudo docker build -t \$IMAGE_NAME .

# Run container
sudo docker run -d --name \$CONTAINER_NAME -p $APP_PORT:80 \$IMAGE_NAME

# Configure Nginx reverse proxy
echo "server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://localhost:$APP_PORT;
    }
}" | sudo tee /etc/nginx/sites-available/hng-app

sudo ln -sf /etc/nginx/sites-available/hng-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

echo " Remote deployment completed successfully!"
EOF

echo ""
echo "🔍 Verifying live deployment on http://$SERVER_IP ..."
if curl -s --head --request GET http://$SERVER_IP | grep "200 OK" > /dev/null; then
    echo " Verification successful! Application is live and reachable."
    echo " Visit: http://$SERVER_IP"
else
    echo " Verification failed! Check the server or logs."
fi

echo ""
echo " Deployment process finished successfully!"
