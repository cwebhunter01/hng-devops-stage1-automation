#!/bin/bash

# === HNG Stage 1 Automated Deployment Script ===
# Author: Adeyemi Favour (cwebhunter01)
# Description: Automates cloning, building, and deploying a Dockerized app with Nginx reverse proxy on a remote server.

set -e  # Exit immediately on any command failure
set -o pipefail

# ===== STEP 1: Logging Setup =====
LOG_FILE="deployment.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🚀 Starting Automated Deployment Script..."

# ===== STEP 1: Collect Parameters =====
read -p "Enter GitHub repository URL: " REPO_URL
read -p "Enter your Personal Access Token (PAT): " PAT
read -p "Enter branch name (default: main): " BRANCH
read -p "Enter SSH username for remote server: " SSH_USER
read -p "Enter Server IP address: " SERVER_IP
read -p "Enter path to your SSH private key (e.g., ~/.ssh/id_rsa): " SSH_KEY
read -p "Enter application port (internal container port): " APP_PORT

BRANCH=${BRANCH:-main}

if [[ -z "$REPO_URL" || -z "$PAT" || -z "$SSH_USER" || -z "$SERVER_IP" || -z "$SSH_KEY" || -z "$APP_PORT" ]]; then
  echo "❌ Error: All fields are required!"
  exit 1
fi

echo ""
echo "✅ Parameters collected successfully!"
echo "Repository: $REPO_URL"
echo "Branch: $BRANCH"
echo "Server: $SSH_USER@$SERVER_IP"
echo "Port: $APP_PORT"
echo ""

# ===== STEP 2: Clone Repository =====
echo "📦 Cloning repository or pulling latest changes..."

if [ -d "repo" ]; then
    echo "Repository already exists. Pulling latest changes..."
    cd repo || exit 1
    git pull origin "$BRANCH"
else
    echo "Cloning repository..."
    git clone --branch "$BRANCH" "https://$PAT@github.com/${REPO_URL#https://github.com/}" repo || {
        echo "❌ Failed to clone repository!"
        exit 1
    }
    cd repo || exit 1
fi

if [ ! -f Dockerfile ] && [ ! -f docker-compose.yml ]; then
  echo "❌ Error: No Dockerfile or docker-compose.yml found in repository!"
  exit 1
else
  echo "✅ Repository cloned and Dockerfile verified."
fi

# ===== STEP 3: SSH Into Remote Server =====
echo "🔹 Connecting to EC2 instance and preparing environment..."
ssh -i $SSH_KEY $SSH_USER@$SERVER_IP <<EOF
  set -e
  echo "🛠️ Updating server and installing dependencies..."
  sudo apt update -y
  sudo apt install -y docker.io nginx git

  sudo systemctl enable docker
  sudo systemctl start docker
  sudo systemctl enable nginx
  sudo systemctl start nginx

  echo "📁 Setting up application directory..."
  sudo rm -rf /var/www/hng-app
  sudo mkdir -p /var/www/hng-app
  cd /var/www/hng-app

  echo "📥 Cloning latest code from GitHub..."
  sudo git clone https://github.com/cwebhunter01/hng-devops-stage1-automation.git . || true

  echo "🧹 Cleaning up old Docker container if it exists..."
  if [ "\$(sudo docker ps -aq -f name=hng-app)" ]; then
      sudo docker stop hng-app || true
      sudo docker rm hng-app || true
  fi

  echo "🐳 Building new Docker image..."
  sudo docker build -t hng-app .

  echo "🚀 Running new Docker container..."
  sudo docker run -d --name hng-app -p 8080:80 hng-app

  echo "🌐 Configuring Nginx reverse proxy..."
  echo "server {
      listen 80;
      server_name _;
      location / {
          proxy_pass http://localhost:8080;
      }
  }" | sudo tee /etc/nginx/sites-available/hng-app

  sudo ln -sf /etc/nginx/sites-available/hng-app /etc/nginx/sites-enabled/
  sudo nginx -t && sudo systemctl reload nginx

  echo "✅ Deployment completed successfully!"
EOF

echo ""
echo "🎯 Deployment completed successfully!"
echo "📝 Local log file saved at: $LOG_FILE"
echo "🧾 Remote log file: /var/log/hng-deployment.log"
echo ""
echo "🎯 All done! Visit your app at: http://$SERVER_IP/"
