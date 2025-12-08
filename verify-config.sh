#!/bin/bash
# Configuration Verification Script
# This script verifies all public EC2 addresses and port configurations

echo "================================"
echo "PRESCRIPTO CONFIGURATION AUDIT"
echo "================================"
echo ""

PUBLIC_IP="43.204.98.50"
BACKEND_PORT="4001"
FRONTEND_PORT="5174"

echo "✓ Public EC2 Address: $PUBLIC_IP"
echo ""

echo "--- Configuration Files Check ---"
echo ""

# Check clientside/.env
echo "1. clientside/.env"
if grep -q "VITE_BACKEND_URL=http://43.204.98.50:4001" clientside/.env; then
    echo "   ✓ Correct backend URL with port 4001"
else
    echo "   ✗ INCORRECT: Backend URL may be wrong"
fi

# Check admin/.env
echo "2. admin/.env"
if grep -q "VITE_BACKEND_URL=http://43.204.98.50:4001" admin/.env; then
    echo "   ✓ Correct backend URL with port 4001"
else
    echo "   ✗ INCORRECT: Backend URL may be wrong"
fi

# Check backend/.env
echo "3. backend/.env"
if grep -q "PORT=4000" backend/.env; then
    echo "   ✓ Correct internal port 4000"
else
    echo "   ✗ INCORRECT: Backend port may be wrong"
fi

# Check conftest.py
echo "4. conftest.py"
if grep -q "BASE_URL = \"http://43.204.98.50:5174\"" conftest.py; then
    echo "   ✓ Correct BASE_URL"
else
    echo "   ✗ INCORRECT: BASE_URL may be wrong"
fi

if grep -q "BACKEND_URL = \"http://43.204.98.50:4001\"" conftest.py; then
    echo "   ✓ Correct BACKEND_URL"
else
    echo "   ✗ INCORRECT: BACKEND_URL missing or wrong"
fi

if grep -q "/usr/bin/chromedriver" conftest.py; then
    echo "   ✓ Uses system chromedriver"
else
    echo "   ✗ INCORRECT: May still use webdriver-manager"
fi

# Check docker-compose-part2.yml
echo "5. docker-compose-part2.yml"
if grep -q "4001:4000" docker-compose-part2.yml; then
    echo "   ✓ Correct backend port mapping (4001:4000)"
else
    echo "   ✗ INCORRECT: Backend port mapping may be wrong"
fi

if grep -q "5174:5173" docker-compose-part2.yml; then
    echo "   ✓ Correct frontend port mapping (5174:5173)"
else
    echo "   ✗ INCORRECT: Frontend port mapping may be wrong"
fi

if grep -q "VITE_BACKEND_URL=http://43.204.98.50:4001" docker-compose-part2.yml; then
    echo "   ✓ Correct VITE_BACKEND_URL in docker-compose"
else
    echo "   ✗ INCORRECT: VITE_BACKEND_URL in docker-compose may be wrong"
fi

# Check Dockerfile.tests
echo "6. Dockerfile.tests"
if grep -q "chromium-driver" Dockerfile.tests; then
    echo "   ✓ Installs chromium-driver package"
else
    echo "   ✗ INCORRECT: chromium-driver not installed"
fi

if grep -q "/usr/bin/chromedriver" Dockerfile.tests || grep -q "chromedriver --version" Dockerfile.tests; then
    echo "   ✓ Uses system chromedriver"
else
    echo "   ✗ INCORRECT: May not use system chromedriver"
fi

# Check Jenkinsfile.part2
echo "7. Jenkinsfile.part2"
if grep -q "BACKEND_URL = \"http://43.204.98.50:4001\"" Jenkinsfile.part2; then
    echo "   ✓ Correct BACKEND_URL in environment"
else
    echo "   ✗ INCORRECT: BACKEND_URL may be wrong"
fi

if grep -q "FRONTEND_URL = \"http://43.204.98.50:5174\"" Jenkinsfile.part2; then
    echo "   ✓ Correct FRONTEND_URL in environment"
else
    echo "   ✗ INCORRECT: FRONTEND_URL may be wrong"
fi

echo ""
echo "================================"
echo "Endpoint Summary"
echo "================================"
echo "Frontend:        http://$PUBLIC_IP:$FRONTEND_PORT"
echo "Admin Panel:     http://$PUBLIC_IP:$FRONTEND_PORT/admin"
echo "Backend API:     http://$PUBLIC_IP:$BACKEND_PORT"
echo "Database:        Internal (MongoDB Atlas)"
echo ""
echo "✓ Verification Complete"
