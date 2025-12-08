# Part 2: Jenkins Pipeline Automation Guide

## Overview
This guide covers setting up a Jenkins pipeline that:
1. ✅ Triggers on GitHub push
2. ✅ Deploys the application using Docker Compose
3. ✅ Runs automated Selenium tests
4. ✅ Emails test results to the collaborator

---

## Step 1: Push Test Code to GitHub Repository

### 1.1 Initialize Git Repository (If Not Done)
```bash
cd d:\Documents\sem7\Devops\assignment3\prescripto-main
git init
git add .
git commit -m "Part 1: Add Selenium test cases and Part 2: Add Jenkins pipeline"
```

### 1.2 Add Remote Repository
```bash
git remote add origin https://github.com/YOUR_USERNAME/prescripto.git
git branch -M main
git push -u origin main
```

### 1.3 Required Files in GitHub
Ensure these files are committed and pushed:
- ✅ `test_prescripto_e2e.py` - Your 24 test cases
- ✅ `conftest.py` - Pytest configuration and fixtures
- ✅ `requirements.txt` - Python dependencies
- ✅ `Dockerfile.tests` - Docker image for running tests
- ✅ `Jenkinsfile.part2` - Enhanced Jenkins pipeline with test stage
- ✅ `docker-compose-part2.yml` - Application deployment configuration
- ✅ All backend/ and clientside/ source code

### 1.4 Verify GitHub Setup
```bash
git remote -v  # Should show your GitHub repo
git log --oneline  # Should show your commits
```

---

## Step 2: Configure AWS EC2 Instance for Jenkins

### 2.1 Connect to Your EC2 Instance
```bash
# SSH into your EC2 instance
ssh -i your-key.pem ec2-user@YOUR_EC2_PUBLIC_IP

# Update system packages
sudo yum update -y
```

### 2.2 Install Docker on EC2
```bash
# Install Docker
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

### 2.3 Install Jenkins
```bash
# Install Java
sudo yum install java-11-openjdk -y

# Add Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install Jenkins
sudo yum install jenkins -y

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Get Jenkins initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 2.4 Access Jenkins Web UI
- Go to: `http://YOUR_EC2_PUBLIC_IP:8080`
- Use the initial password from step 2.3
- Install suggested plugins
- Create admin user

---

## Step 3: Install Jenkins Plugins

In Jenkins UI:
1. Go to **Manage Jenkins** → **Manage Plugins**
2. Search and install:
   - ✅ GitHub Integration
   - ✅ Pipeline
   - ✅ Docker Pipeline
   - ✅ Email Extension
   - ✅ JUnit Plugin
   - ✅ HTML Publisher Plugin

---

## Step 4: Create GitHub Personal Access Token

### 4.1 Generate Token
1. Go to GitHub → Settings → Developer settings → Personal access tokens
2. Click "Generate new token"
3. Select scopes: `repo`, `admin:repo_hook`, `user`
4. Copy the token (you won't see it again!)

### 4.2 Add Token to Jenkins
1. Jenkins → Manage Jenkins → Manage Credentials
2. Click "Global" → "Add Credentials"
3. Type: **Username with password**
   - Username: Your GitHub username
   - Password: Your personal access token
   - ID: `github-credentials`
4. Click **OK**

---

## Step 5: Configure Jenkins Pipeline Job

### 5.1 Create New Pipeline Job
1. Jenkins → New Item
2. Name: `Prescripto-Test-Pipeline`
3. Type: **Pipeline**
4. Click **OK**

### 5.2 Configure Pipeline Source
1. Go to **Pipeline** section
2. Select: **Pipeline script from SCM**
3. SCM: **Git**
4. Repository URL: `https://github.com/YOUR_USERNAME/prescripto.git`
5. Credentials: `github-credentials`
6. Branch: `*/main`
7. Script Path: `Jenkinsfile.part2`
8. Click **Save**

---

## Step 6: Configure GitHub Webhook

### 6.1 On GitHub
1. Go to your repository → Settings → Webhooks
2. Click **Add webhook**
3. Payload URL: `http://YOUR_EC2_PUBLIC_IP:8080/github-webhook/`
4. Content type: `application/json`
5. Events: **Push events** and **Pull requests**
6. Active: ✅ Checked
7. Click **Add webhook**

### 6.2 Verify Webhook
- Green checkmark ✅ means webhook is working
- If red ❌, check Jenkins logs and EC2 security groups

---

## Step 7: Configure Email Notifications

### 7.1 Set SMTP Server in Jenkins
1. Jenkins → Manage Jenkins → Configure System
2. Find **E-mail Notification**
3. SMTP server: `smtp.gmail.com` (for Gmail)
4. SMTP port: `587`
5. Check: **Use SMTP Authentication**
6. Username: Your Gmail
7. Password: Gmail app password (not regular password)
8. Check: **Use TLS**
9. Test email address: Your email
10. Click **Test configuration**
11. Click **Save**

### 7.2 Create Gmail App Password
1. Google Account → Security
2. Enable 2-Factor Authentication
3. Go to App Passwords
4. Select: Mail and Windows PC
5. Copy the generated password (16 characters)
6. Use this in Jenkins SMTP settings

---

## Step 8: Update conftest.py for Jenkins Environment

Update the base URL to work with Docker containers:

```python
# conftest.py - Updated for Docker environment
BASE_URL = os.getenv("FRONTEND_URL", "http://localhost:5174")
ADMIN_BASE_URL = os.getenv("ADMIN_URL", "http://localhost:5174")
```

---

## Step 9: Update requirements.txt

Ensure all dependencies are included:

```txt
selenium>=4.0
pytest>=9.0
pytest-html>=3.2
pytest-xdist>=3.0
webdriver-manager>=4.0
```

---

## Step 10: Test the Pipeline

### 10.1 Manual Trigger
1. Jenkins → Prescripto-Test-Pipeline
2. Click **Build Now**
3. Monitor the build in real-time

### 10.2 Check Build Output
1. Click on the build number (#1, #2, etc.)
2. Click **Console Output**
3. You should see:
   - ✅ Code checkout
   - ✅ Docker containers starting
   - ✅ Tests running
   - ✅ Results collected

### 10.3 View Test Reports
1. Go to build → **Test Report**
2. See breakdown of all 24 tests
3. Click individual tests for details

---

## Step 11: Trigger Pipeline via GitHub Push

### 11.1 Make a Code Change
```bash
# In your local repository
echo "# Updated README" >> README.md
git add README.md
git commit -m "Test pipeline trigger from GitHub push"
git push origin main
```

### 11.2 Verify Pipeline Triggered
1. Go to Jenkins → Prescripto-Test-Pipeline
2. You should see a new build started automatically
3. Check **Build History** on the left

### 11.3 Check Email Notification
- Check your email inbox for test results
- Should include:
  - Build status (✅ Success or ❌ Failed)
  - Test results summary
  - Link to detailed reports
  - Commit author info

---

## Step 12: Troubleshooting

### Docker Containers Not Starting
```bash
# SSH into EC2 and check:
docker-compose -f docker-compose-part2.yml logs
docker ps -a
```

### Tests Not Running
```bash
# Check test container logs:
docker logs prescripto-tests
```

### Webhook Not Triggering
1. Check GitHub Webhook Deliveries tab for errors
2. Verify EC2 Security Group allows port 8080
3. Check Jenkins firewall rules

### Email Not Sending
1. Verify SMTP configuration in Jenkins
2. Check Gmail app password (not regular password)
3. Enable 2FA on Gmail account
4. Check Jenkins logs: `/var/log/jenkins/jenkins.log`

---

## Step 13: File Structure for Submission

Ensure your GitHub repository contains:

```
prescripto-main/
├── README.md
├── Jenkinsfile.part2          (Enhanced pipeline with tests)
├── Dockerfile.tests           (Test Docker image)
├── requirements.txt           (Python dependencies)
├── conftest.py               (Pytest fixtures)
├── test_prescripto_e2e.py    (24 test cases)
├── docker-compose-part2.yml  (Application deployment)
├── backend/                  (Backend source code)
├── clientside/               (Frontend source code)
├── admin/                    (Admin panel source code)
└── aws/                      (AWS deployment configs)
```

---

## Step 14: Documentation for Report

Create a `PART2_REPORT.md` file with:

1. **Architecture Diagram** - Show Jenkins → GitHub → Docker → Tests flow
2. **Setup Steps** - Detailed steps performed
3. **Screenshots**:
   - ✅ GitHub repository with files
   - ✅ GitHub webhook configuration
   - ✅ Jenkins pipeline job configuration
   - ✅ Successful build with test results
   - ✅ Email notification example
   - ✅ Test report HTML page
4. **Pipeline Script** - Full Jenkinsfile.part2 content
5. **Docker Configuration** - Dockerfile.tests content
6. **Test Results** - Summary of all 24 tests

---

## Quick Reference Commands

```bash
# View Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Restart Jenkins
sudo systemctl restart jenkins

# SSH to EC2
ssh -i your-key.pem ec2-user@IP

# Docker commands
docker ps                           # List running containers
docker logs <container-id>          # View container logs
docker-compose -f docker-compose-part2.yml logs
docker-compose -f docker-compose-part2.yml down

# Git commands
git push origin main
git log --oneline
git status
```

---

## Success Criteria Checklist

- ✅ Test code pushed to GitHub
- ✅ Jenkins job created and configured
- ✅ GitHub webhook configured
- ✅ Docker image builds successfully
- ✅ Tests run in Docker container
- ✅ Email notifications sent on success/failure
- ✅ Pipeline triggered by GitHub push
- ✅ All 24 tests pass in Jenkins pipeline
- ✅ Comprehensive report created
- ✅ Instructor added as collaborator

---

## Support & Contact

For issues, check:
1. Jenkins Console Output
2. Docker container logs
3. GitHub webhook delivery logs
4. AWS Security Group settings
5. Email SMTP configuration

---

**Next Steps:**
1. Push your code to GitHub
2. Set up AWS EC2 instance
3. Install and configure Jenkins
4. Create GitHub webhook
5. Run manual build test
6. Verify email notifications
7. Create comprehensive report

Good luck! 🚀
