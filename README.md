# 🚀 HNG DevOps Stage 1 – Automated Deployment

## 📝 Project Description
This project automates the deployment of a simple static website using **Bash, Docker, and Nginx**.  
It pulls the latest code from GitHub, builds a Docker image, runs the container, and configures Nginx automatically on a remote Ubuntu server.

The goal of this project is to demonstrate the ability to automate deployments — from code retrieval to live server setup — using a single script.

---

## 📂 Project Files
| File | Description |
|------|--------------|
| `index.html` | The static web page served via Nginx. |
| `Dockerfile` | Defines the Docker image for the web app. |
| `deploy.sh` | Bash automation script for deployment. |
| `README.md` | Documentation for setup and execution. |

---

## ⚙️ Technologies Used
- **Ubuntu 24.04 LTS**
- **Docker**
- **Nginx**
- **Git**
- **Bash Script**

---

## 🧠 How It Works
The `deploy.sh` script performs the following steps automatically:

1. Collects deployment parameters such as GitHub repo URL, SSH key, and server details.  
2. Clones or pulls the latest code from GitHub.  
3. Connects to the remote server using SSH.  
4. Installs required dependencies: **Docker**, **Nginx**, and **Git**.  
5. Builds and runs the Docker container from the `Dockerfile`.  
6. Configures **Nginx** as a reverse proxy to route HTTP requests to the container.  
7. Restarts Nginx and finalizes the deployment process.

---

## 🧩 Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/cwebhunter01/hng-devops-stage1-automation.git
cd hng-devops-stage1-automation
### Script Executable 
chmod +x deploy.sh
### Run The Script 
./deploy.sh

You’ll be prompted to enter:
GitHub repository URL
Personal Access Token (PAT)
Branch name (default: main)
SSH username and IP address of your server
Path to your SSH private key
Application internal port
The script will automatically handle cloning, building, and deploying your web app.


### Live URL

Access the deployed web application at:
👉 http://54.219.162.73
###Author
Adeyemi Favour
HNG DevOps Intern — Stage 1 Challenge
GitHub: cwebhunter01
