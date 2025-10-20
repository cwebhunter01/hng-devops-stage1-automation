# HNG DevOps Stage 1 - Deployment Automation

## Description
This project is a simple automated deployment setup using **Bash, Docker, and Nginx**.  
It deploys a static website (`index.html`) to an Ubuntu server automatically using the `deploy.sh` script.

---

## Project Files
- `index.html` — The web page to be served.
- `Dockerfile` — Builds the Docker image for the application.
- `deploy.sh` — Automates deployment on a remote server.
- `README.md` — Project documentation.

---

## Technologies Used
- Ubuntu 24.04 LTS
- Docker
- Nginx
- Git
- Bash Script

---

## How to Run the Script

### 1. Clone the Repository
```bash
git clone https://github.com/cwebhunter01/hng-devops-stage1-automation.git
cd hng-devops-stage1-automation

### 2. Make the Script Executable 
chmod +x deploy.sh

### 3. Run The Script
./deploy.sh

This script installs dependencies, clones the repo on the remote server,
 builds the Docker image, and configures Nginx automatically.

### Live URL
The App is live at:

http://http://54.219.162.73

### Author
Adeyemi Favour
HNG Devops Intern - Stage 1 Challenge 
github:https://github.com/cwebhunter01 
