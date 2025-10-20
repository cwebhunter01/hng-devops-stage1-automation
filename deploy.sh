#!/bin/bash

# === HNG Stage 1 Deployment Script ===

# Exit immediately if any command fails
set -e

# Variables
REPO_URL="https://github.com/cwebhunter01/hng-devops-stage1-automation.git"
APP_DIR="hng-app"
SERVER_IP="54.219.162.73"
SSH_KEY="~/.ssh/hng-key.pem"
REMOTE_USER="ubuntu"

# Step 1: SSH into the server and set up environment
echo "🔹 Connecting to EC2 instance and preparing environment..."
ssh -i $SSH_KEY $REMOTE_USER@$SERVER_IP << 'EOF'
  sudo apt update -y
  sudo apt install -y docker.io nginx
  sudo systemctl enable docker
  sudo systemctl start docker

  # Clean old deployment if any
  sudo rm -rf /var/www/hng-app
  sudo mkdir -p /var/www/hng-app
  cd /var/www/hng-app

  # Clone latest version
  sudo apt install -y git
  sudo git clone https://github.com/cwebhunter01/hng-devops-stage1-automation.git .
  # Build Docker container
  sudo docker build -t hng-app .
  sudo docker run -d -p 8080:80 hng-app

  # Configure Nginx
  echo "server {
      listen 80;
      server_name _;
      location / {
          proxy_pass http://localhost:8080;
      }
  }" | sudo tee /etc/nginx/sites-available/hng-app

  sudo ln -sf /etc/nginx/sites-available/hng-app /etc/nginx/sites-enabled/
  sudo nginx -t && sudo systemctl restart nginx

  echo "✅ Deployment completed successfully!"
EOF
