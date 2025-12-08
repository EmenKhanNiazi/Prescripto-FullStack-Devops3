# Part 2: Jenkins Pipeline Automation - Quick Start Guide

## 📋 What You Need

- ✅ **24 passing Selenium tests** (Already done!)
- ✅ **GitHub repository** with test code
- ✅ **AWS EC2 instance** for Jenkins
- ✅ **Docker** and **Docker Compose** installed
- ✅ **Jenkins** server running

---

## 🚀 Quick Start (5 Steps)

### Step 1: Prepare Your GitHub Repository

#### 1.1 Make sure all files are committed
```bash
cd d:\Documents\sem7\Devops\assignment3\prescripto-main

# Check git status
git status

# Add all files
git add .

# Commit
git commit -m "Part 2: Add Jenkinsfile with test stage, Dockerfile.tests, and updated requirements"

# Push to GitHub
git push origin main
```

#### 1.2 Verify files on GitHub
Go to your repository and confirm:
- ✅ `Jenkinsfile` (updated with test stage)
- ✅ `Dockerfile.tests` (new)
- ✅ `requirements.txt` (updated with test dependencies)
- ✅ `test_prescripto_e2e.py` (24 test cases)
- ✅ `conftest.py` (pytest configuration)
- ✅ `docker-compose-part2.yml` (application deployment)

---

### Step 2: Set Up AWS EC2 (Connect via SSH)

```bash
# 1. SSH to your EC2 instance
ssh -i your-key-file.pem ec2-user@YOUR_EC2_PUBLIC_IP

# 2. Update system
sudo yum update -y

# 3. Install Docker
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# 4. Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 5. Verify installations
docker --version
docker-compose --version

# 6. Install Java (required for Jenkins)
sudo yum install java-11-openjdk -y

# 7. Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y

# 8. Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# 9. Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

### Step 3: Configure Jenkins Web UI

#### 3.1 Access Jenkins
- Open browser: `http://YOUR_EC2_PUBLIC_IP:8080`
- Enter the initial password from Step 2

#### 3.2 Complete Setup Wizard
1. Select **Install suggested plugins**
2. Create first admin user
3. Confirm Jenkins URL

#### 3.3 Install Additional Plugins
1. Go to **Manage Jenkins** → **Manage Plugins**
2. Search for and install:
   - ✅ GitHub Integration
   - ✅ Pipeline
   - ✅ Docker Pipeline
   - ✅ Email Extension
   - ✅ JUnit Plugin
   - ✅ HTML Publisher

#### 3.4 Configure Email (Gmail Example)
1. **Manage Jenkins** → **Configure System**
2. Find **E-mail Notification**
3. Set:
   - SMTP Server: `smtp.gmail.com`
   - SMTP Port: `587`
   - Username: your-gmail@gmail.com
   - Password: `Your Gmail App Password` (from Google Account Settings → Security → App Passwords)
   - Check: **Use TLS**
4. Click **Test configuration** and send test email
5. Click **Save**

---

### Step 4: Create GitHub Credentials in Jenkins

1. **Manage Jenkins** → **Manage Credentials**
2. Click **Global** → **Add Credentials**
3. Fill in:
   - Kind: **Username with password**
   - Username: `YOUR_GITHUB_USERNAME`
   - Password: `YOUR_GITHUB_PERSONAL_ACCESS_TOKEN`
   - ID: `github-credentials`
4. Click **Create**

**How to get GitHub Personal Access Token:**
1. GitHub → Settings → Developer settings → Personal access tokens
2. Click **Tokens (classic)** → **Generate new token (classic)**
3. Select: `repo`, `admin:repo_hook`, `user`
4. Copy token (only shown once!)

---

### Step 5: Create Jenkins Pipeline Job

#### 5.1 Create New Job
1. Jenkins → **New Item**
2. Name: `Prescripto-Pipeline`
3. Type: **Pipeline**
4. Click **OK**

#### 5.2 Configure Pipeline
1. Under **Pipeline** section, select: **Pipeline script from SCM**
2. Set:
   - SCM: **Git**
   - Repository URL: `https://github.com/YOUR_USERNAME/prescripto.git`
   - Credentials: `github-credentials`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
3. Click **Save**

#### 5.3 Set Up GitHub Webhook
1. Go to your GitHub repository → **Settings** → **Webhooks**
2. Click **Add webhook**
3. Set:
   - Payload URL: `http://YOUR_EC2_PUBLIC_IP:8080/github-webhook/`
   - Content type: `application/json`
   - Events: Select **Push events** and **Pull requests**
   - Active: ✅ Checked
4. Click **Add webhook**

---

## 🧪 Test Your Pipeline

### Test 1: Manual Trigger
```
Jenkins → Prescripto-Pipeline → Build Now
```

### Test 2: Check Build Output
1. Click on build #1
2. Click **Console Output**
3. You should see all stages executing

### Test 3: View Test Results
1. Go to build page
2. Click **Test Report**
3. See all 24 tests listed

### Test 4: Check Email
- Look for email with subject: `✅ SUCCESS: Prescripto Pipeline #1`

### Test 5: GitHub Push Trigger
```bash
cd your-local-repo
echo "# Test commit" >> README.md
git add .
git commit -m "Testing webhook trigger"
git push origin main

# Go to Jenkins → Prescripto-Pipeline
# Should automatically build within 10 seconds
```

---

## 📊 File Structure

Your GitHub repository should have:

```
prescripto-main/
├── Jenkinsfile                  ← Updated with test stage
├── Dockerfile.tests             ← NEW: For running tests
├── requirements.txt             ← Updated with test libs
├── conftest.py                  ← Pytest fixtures
├── test_prescripto_e2e.py       ← 24 test cases
├── docker-compose-part2.yml     ← Application deployment
├── PART2_SETUP_GUIDE.md         ← Detailed setup guide
├── backend/                     ← Backend source
├── clientside/                  ← Frontend source
├── admin/                       ← Admin panel source
└── README.md
```

---

## 🔍 Troubleshooting

| Issue | Solution |
|-------|----------|
| Jenkins won't start | Check: `sudo systemctl status jenkins` |
| Docker not found | Reinstall: `sudo yum install docker -y` |
| Webhook not triggering | Check webhook deliveries on GitHub, verify EC2 security group allows 8080 |
| Tests failing | Check: `docker logs <container-id>` |
| Email not sending | Verify Gmail app password is correct (not regular password) |
| Pipeline stuck | Check Jenkins logs: `sudo tail -f /var/log/jenkins/jenkins.log` |

---

## 📝 For Your Assignment Report

Include:

1. **Architecture Diagram**
   ```
   GitHub Push
        ↓
   Webhook Trigger
        ↓
   Jenkins Pipeline
        ↓
   ├─ Checkout Code
   ├─ Deploy with Docker
   ├─ Run Tests in Container
   ├─ Collect Results
   └─ Email Notification
   ```

2. **Screenshots**
   - GitHub repository with files
   - GitHub webhook configuration
   - Jenkins pipeline job configuration
   - Successful build output
   - Test report (24 tests passing)
   - Email notification

3. **Jenkins Pipeline Script**
   - Full Jenkinsfile content

4. **Docker Configuration**
   - Dockerfile.tests content

5. **Test Results**
   - Summary of all 24 tests

---

## ✅ Success Checklist

- [ ] All test code pushed to GitHub
- [ ] Jenkins installed and running on EC2
- [ ] GitHub credentials configured in Jenkins
- [ ] Pipeline job created
- [ ] GitHub webhook configured
- [ ] Manual build executed successfully
- [ ] All 24 tests passed in Jenkins
- [ ] Email notification received
- [ ] GitHub push automatically triggered pipeline
- [ ] Report created with screenshots

---

## 🎯 Next Steps

1. **Complete Step 1-5** above
2. **Test the pipeline** manually
3. **Make a GitHub push** to test webhook
4. **Verify email notification** arrives
5. **Create comprehensive report** for submission
6. **Submit** via Google Form with:
   - GitHub repository URL
   - Jenkins pipeline URL
   - Application deployment URL

---

## 📞 Quick Commands Reference

```bash
# SSH to EC2
ssh -i key.pem ec2-user@IP

# Check Jenkins status
sudo systemctl status jenkins

# View Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Docker commands
docker ps
docker logs container-id
docker-compose -f docker-compose-part2.yml logs

# Git commands
git push origin main
git log --oneline
```

---

**Good luck with Part 2! 🚀**

For detailed information, see `PART2_SETUP_GUIDE.md`
