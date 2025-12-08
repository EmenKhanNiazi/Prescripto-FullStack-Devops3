#!/bin/bash
# setup-jenkins.sh - Automated Jenkins setup for Part 2
# Run this script on your AWS EC2 instance to set everything up

set -e  # Exit on error

echo "=========================================="
echo "Prescripto Part 2: Jenkins Setup Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Step 1: Update System
echo ""
echo "Step 1: Updating system packages..."
sudo yum update -y
print_step "System updated"

# Step 2: Install Java
echo ""
echo "Step 2: Installing Java..."
sudo yum install java-11-openjdk -y
print_step "Java installed: $(java -version 2>&1 | head -1)"

# Step 3: Install Docker
echo ""
echo "Step 3: Installing Docker..."
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
print_step "Docker installed: $(docker --version)"

# Step 4: Install Docker Compose
echo ""
echo "Step 4: Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
print_step "Docker Compose installed: $(docker-compose --version)"

# Step 5: Install Jenkins
echo ""
echo "Step 5: Installing Jenkins..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
print_step "Jenkins installed"

# Step 6: Start Jenkins
echo ""
echo "Step 6: Starting Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins
print_step "Jenkins started and enabled"

# Wait for Jenkins to be ready
echo ""
echo "⏳ Waiting for Jenkins to initialize (30 seconds)..."
sleep 30

# Step 7: Display Jenkins Password
echo ""
echo "=========================================="
echo "Jenkins Setup Complete!"
echo "=========================================="
echo ""
print_step "Jenkins is running on port 8080"
echo ""
print_warning "IMPORTANT: Jenkins Initial Setup Token:"
echo ""
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Get your EC2 Public IP"
echo "2. Go to http://YOUR_EC2_IP:8080"
echo "3. Enter the initial token above"
echo "4. Install suggested plugins"
echo "5. Create admin user"
echo "6. Follow PART2_QUICK_START.md for pipeline setup"
echo ""
echo "=========================================="
