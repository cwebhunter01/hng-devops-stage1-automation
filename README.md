# HNG DevOps Stage 1 – Deployment Automation

## Description
This project automates the deployment of a static website (`index.html`) using **Bash, Docker, and Nginx**.  
The `deploy.sh` script handles **full deployment on a remote Ubuntu server**, including environment setup, Docker containerization, Nginx reverse proxy configuration, and live verification.

---

## Project Files
- `index.html` — Static web page to be served.  
- `Dockerfile` — Builds the Docker image for the application.  
- `deploy.sh` — Fully automated deployment script.  
- `README.md` — Project documentation.  

---

## Technologies Used
- Ubuntu 24.04 LTS  
- Docker  
- Nginx  
- Git  
- Bash  

---

## Features of the Deployment Script
The `deploy.sh` script performs the following tasks:

1. Collects all deployment parameters from the user:
   - GitHub repository URL
   - Personal Access Token (PAT)
   - Branch name
   - SSH credentials for remote server
   - Application internal port
2. Validates user input to ensure all required fields are filled.
3. Cleans up **old local logs** (keeps the last 5 deployment logs).  
4. Removes **old local repository folder** to avoid duplication.  
5. Clones the latest repository or pulls updates if it already exists.  
6. Checks for the presence of a Dockerfile or docker-compose.yml.  
7. SSHs into the remote server and prepares the environment:
   - Updates system packages
   - Installs Docker, Nginx, Git, and curl
   - Enables and starts Docker service
8. Stops and removes **any existing container** with the same name.  
9. Removes **old Docker images** to prevent conflicts.  
10. Cleans up **old Docker volumes** related to the app.  
11. Prepares the remote app directory for deployment.  
12. Clones the latest repository to the remote server.  
13. Builds a Docker image for the application.  
14. Runs the Docker container on the specified internal port.  
15. Configures Nginx as a reverse proxy to forward HTTP traffic to the Docker container.  
16. Reloads Nginx and tests its configuration.  
17. Verifies the live deployment using an HTTP request.  
18. Saves the full deployment process to a **timestamped log file**.

---

## How to Run the Script

### 1. Clone the Repository
```bash
git clone https://github.com/cwebhunter01/hng-devops-stage1-automation.git
cd hng-devops-stage1-automation

### Make the Script Executable
chmod +x deploy.sh

### Run the Script
./deploy.sh

The script will prompt you for the required inputs, perform all deployment steps, and log the output.

### LIVE URL.
After deployment, access the application at:

http://54.219.162.73

### AUTHOR
Adeyemi Favour
HNG DevOps Intern – Stage 1 Challenge
GitHub: https://github.com/cwebhunter01
