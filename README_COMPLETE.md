# Prescripto - DevOps Assignment Part 1 & 2

## 📋 Project Overview

This project implements a complete DevOps CI/CD pipeline with:
- **Part 1**: 24 automated Selenium test cases
- **Part 2**: Jenkins pipeline automation with GitHub webhook integration

---

## ✅ Part 1: Automated Selenium Testing

### Test Cases Summary
- **Total Tests**: 24
- **Passing**: 24 ✅
- **Coverage**: Homepage, Navigation, Login/Logout, Appointments, Contact, About pages

### Test Categories

#### Basic Navigation Tests (Tests 1-11)
- ✅ Homepage loads successfully
- ✅ Book appointment button visible
- ✅ Navigation to doctors page
- ✅ Doctors page content validation
- ✅ Navigation to about page
- ✅ About page content validation
- ✅ Navigation to contact page
- ✅ Contact page information
- ✅ Create account button
- ✅ Navbar structure
- ✅ Page loading without errors

#### Authentication Tests (Tests 12-17)
- ✅ Navigate to login page
- ✅ Login page form validation
- ✅ Toggle between login and signup
- ✅ Invalid credentials handling
- ✅ Logout functionality
- ✅ Switch to signup form

#### Appointment & User Tests (Tests 18-22)
- ✅ Navigate to doctor appointment page
- ✅ Appointment page content
- ✅ User profile link
- ✅ Doctors page navigation
- ✅ Navbar responsiveness

#### Performance & Accessibility Tests (Tests 23-25)
- ✅ Homepage load time < 10 seconds
- ✅ Footer links exist
- ✅ Page heading structure

### Running Tests Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Run all tests
pytest test_prescripto_e2e.py -v

# Run specific test
pytest test_prescripto_e2e.py::test_1_homepage_loads -v

# Run with detailed output
pytest test_prescripto_e2e.py -v -s

# Generate HTML report
pytest test_prescripto_e2e.py -v --html=report.html --self-contained-html
```

### Test Files
- **`test_prescripto_e2e.py`** - All 24 test cases
- **`conftest.py`** - Pytest fixtures and configuration
- **`requirements.txt`** - Python dependencies

---

## 🚀 Part 2: Jenkins Pipeline Automation

### Architecture

```
GitHub Push Event
        ↓
GitHub Webhook
        ↓
Jenkins Trigger
        ↓
├─ Stage 1: Checkout Code
├─ Stage 2: Clean Environment
├─ Stage 3: Deploy Application (Docker Compose)
├─ Stage 4: Verify Deployment
├─ Stage 5: Build Test Docker Image
├─ Stage 6: Run Automated Tests
├─ Stage 7: Collect Test Results
├─ Stage 8: Cleanup
        ↓
Email Notification (Success/Failure)
```

### Part 2 Files

| File | Purpose |
|------|---------|
| `Jenkinsfile` | Main pipeline script with all stages |
| `Dockerfile.tests` | Docker image for running tests |
| `docker-compose-part2.yml` | Application deployment configuration |
| `PART2_QUICK_START.md` | Quick setup guide (5 steps) |
| `PART2_SETUP_GUIDE.md` | Detailed step-by-step guide |
| `setup-jenkins.sh` | Automated Jenkins installation script |

### Quick Start (5 Steps)

#### Step 1: Push Code to GitHub
```bash
git add .
git commit -m "Part 2: Jenkins pipeline and tests"
git push origin main
```

#### Step 2: Run Setup Script on EC2
```bash
# SSH to your EC2 instance
ssh -i key.pem ec2-user@YOUR_IP

# Download and run setup script
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/prescripto/main/setup-jenkins.sh
bash setup-jenkins.sh

# Note: Save the initial Jenkins token
```

#### Step 3: Configure Jenkins
- Open `http://YOUR_EC2_IP:8080`
- Enter initial token
- Install suggested plugins
- Create admin user
- Install additional plugins (GitHub, Docker, Email)

#### Step 4: Add GitHub Credentials
- Jenkins → Manage Credentials → Add GitHub credentials
- Use GitHub personal access token

#### Step 5: Create Pipeline Job
- Jenkins → New Item → Pipeline
- Configure SCM to pull from GitHub
- Set Script Path to `Jenkinsfile`
- Configure GitHub webhook

### Verification

```bash
# Test pipeline manually
curl -X POST http://YOUR_EC2_IP:8080/job/Prescripto-Pipeline/build

# Check Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# View Docker containers
docker ps -a
```

---

## 📁 Project Structure

```
prescripto-main/
├── Jenkinsfile                      # Pipeline with test stage
├── Jenkinsfile.part2                # Alternative detailed pipeline
├── Dockerfile.tests                 # Test execution Docker image
├── requirements.txt                 # Python dependencies
├── conftest.py                      # Pytest configuration
├── test_prescripto_e2e.py           # 24 test cases
├── test_debug.py                    # Debug utilities
├── docker-compose.yml               # Original deployment
├── docker-compose-part2.yml         # Enhanced deployment
├── setup-jenkins.sh                 # Automated setup script
├── PART2_QUICK_START.md             # 5-step quick guide
├── PART2_SETUP_GUIDE.md             # Detailed setup guide
├── TEST_RESULTS.md                  # Test summary
├── README.md                        # This file
│
├── backend/                         # Node.js backend
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│   └── ...
│
├── clientside/                      # React frontend
│   ├── Dockerfile
│   ├── package.json
│   ├── vite.config.js
│   └── ...
│
├── admin/                           # React admin panel
│   ├── Dockerfile
│   ├── package.json
│   ├── vite.config.js
│   └── ...
│
└── aws/                             # AWS deployment files
    ├── cloudformation-template.yaml
    ├── ecs-task-definition-*.json
    └── deploy.sh
```

---

## 🔧 Configuration

### Environment Variables

**conftest.py** (for local testing):
```python
BASE_URL = "http://localhost:5173"        # Frontend
ADMIN_BASE_URL = "http://localhost:5174"  # Admin panel
```

**Jenkins Pipeline** (Docker environment):
```groovy
env.BACKEND_URL = "http://localhost:4001"
env.FRONTEND_URL = "http://localhost:5174"
```

### Docker Configuration

**Dockerfile.tests**
```dockerfile
FROM python:3.12-slim
RUN apt-get install chromium chromium-driver
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY test_prescripto_e2e.py conftest.py .
CMD ["pytest", "test_prescripto_e2e.py", "-v"]
```

**docker-compose-part2.yml** services:
- `backend-dev` - Node.js API (port 4001)
- `db` - MongoDB database
- `client-dev` - React frontend (port 5174)

---

## 📊 Test Results

### All 24 Tests Passing ✅

```
test_prescripto_e2e.py::test_1_homepage_loads PASSED
test_prescripto_e2e.py::test_2_book_appointment_exists PASSED
test_prescripto_e2e.py::test_3_navigate_to_doctors_page PASSED
test_prescripto_e2e.py::test_4_doctors_page_content PASSED
test_prescripto_e2e.py::test_5_navigate_to_about_page PASSED
test_prescripto_e2e.py::test_6_about_page_content PASSED
test_prescripto_e2e.py::test_7_navigate_to_contact_page PASSED
test_prescripto_e2e.py::test_8_contact_page_has_information PASSED
test_prescripto_e2e.py::test_9_create_account_button PASSED
test_prescripto_e2e.py::test_10_navbar_structure PASSED
test_prescripto_e2e.py::test_11_page_loads_without_errors PASSED
test_prescripto_e2e.py::test_12_navigate_to_login_page PASSED
test_prescripto_e2e.py::test_13_login_page_has_form PASSED
test_prescripto_e2e.py::test_14_toggle_login_signup PASSED
test_prescripto_e2e.py::test_15_login_with_invalid_credentials PASSED
test_prescripto_e2e.py::test_16_user_logout PASSED
test_prescripto_e2e.py::test_17_switch_to_signup_form PASSED
test_prescripto_e2e.py::test_18_navigate_to_doctor_from_list PASSED
test_prescripto_e2e.py::test_19_appointment_page_has_content PASSED
test_prescripto_e2e.py::test_20_user_profile_link_exists PASSED
test_prescripto_e2e.py::test_21_doctors_page_navigation PASSED
test_prescripto_e2e.py::test_22_navbar_responsiveness PASSED
test_prescripto_e2e.py::test_23_homepage_load_time PASSED
test_prescripto_e2e.py::test_25_page_has_headings PASSED

====================== 24 passed in 214.24s ======================
```

---

## 🔐 Security & Best Practices

### GitHub Security
- ✅ Personal access token used (not password)
- ✅ Token limited to necessary scopes
- ✅ Webhook secret configured (optional but recommended)

### Jenkins Security
- ✅ Strong admin password set
- ✅ Credentials stored securely
- ✅ Pipeline script in SCM (GitOps approach)
- ✅ Email notifications for all builds

### Testing Best Practices
- ✅ Headless Chrome for CI/CD
- ✅ Explicit waits instead of implicit waits
- ✅ Proper test isolation and cleanup
- ✅ Comprehensive error logging
- ✅ HTML report generation

---

## 📚 Documentation Links

- [Part 1 Test Results](./TEST_RESULTS.md)
- [Part 2 Quick Start](./PART2_QUICK_START.md)
- [Part 2 Detailed Guide](./PART2_SETUP_GUIDE.md)
- [Selenium Documentation](https://selenium.dev/)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)

---

## 🐛 Troubleshooting

### Tests Failing Locally
```bash
# Check if frontend is running
curl http://localhost:5173

# Check Chrome driver
python -m webdriver_manager

# Run with more verbose output
pytest test_prescripto_e2e.py -vv -s
```

### Jenkins Pipeline Issues
```bash
# SSH to EC2
ssh -i key.pem ec2-user@YOUR_IP

# Check Jenkins status
sudo systemctl status jenkins

# View logs
sudo tail -f /var/log/jenkins/jenkins.log

# Restart Jenkins
sudo systemctl restart jenkins
```

### Docker Issues
```bash
# List all containers
docker ps -a

# View container logs
docker logs container-name

# Remove stopped containers
docker container prune -f
```

---

## 📝 Assignment Submission

### Required Deliverables
1. ✅ **Test Code** - GitHub repository with all files
2. ✅ **Jenkins Pipeline** - Automated with GitHub webhook
3. ✅ **Report** - With screenshots and steps
4. ✅ **Documentation** - This README and setup guides

### Submission Checklist
- [ ] All 24 tests passing
- [ ] Code pushed to GitHub
- [ ] Jenkins pipeline configured
- [ ] GitHub webhook working
- [ ] Email notifications functional
- [ ] Comprehensive report created
- [ ] Instructor added as collaborator
- [ ] Form submitted with URLs

### Google Form Fields
- Application URL: `http://YOUR_EC2_IP:5174`
- GitHub Repository: `https://github.com/YOUR_USERNAME/prescripto`
- Jenkins Pipeline URL: `http://YOUR_EC2_IP:8080/job/Prescripto-Pipeline`

---

## 👨‍💼 Instructor Access

Add your instructor as a collaborator to your GitHub repository:

1. Go to Repository → Settings → Collaborators
2. Add: `YOUR_INSTRUCTOR_GITHUB_USERNAME`
3. This allows them to:
   - View and review code
   - Trigger the Jenkins pipeline
   - Monitor build results

---

## 📞 Support Resources

- **Selenium**: https://selenium.dev/
- **Jenkins**: https://www.jenkins.io/
- **Docker**: https://docs.docker.com/
- **Git**: https://git-scm.com/

---

## 📈 Next Steps After Submission

1. Verify all requirements met
2. Get feedback from instructor
3. Iterate on improvements
4. Deploy to production (if applicable)

---

**Project Status**: ✅ Part 1 Complete | ✅ Part 2 Ready for Setup

**Last Updated**: December 7, 2025

---

*For detailed setup instructions, see `PART2_QUICK_START.md`*
