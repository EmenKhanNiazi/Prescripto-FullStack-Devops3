# Prescripto Pipeline - Fixes Applied

## Issues Found and Fixed

### 1. **ChromeDriver Version Mismatch** (CRITICAL)
**Problem**: 
- Chromium browser version: 143.0.7499.40
- ChromeDriver version: 114
- Mismatch causes: `SessionNotCreatedException: This version of ChromeDriver only supports Chrome version 114`

**Solution**:
- Updated `Dockerfile.tests` to install `chromium-driver` package alongside `chromium`
- This ensures chromedriver and chromium versions are synchronized from the same package
- Modified `conftest.py` to use system `/usr/bin/chromedriver` directly instead of webdriver-manager
- Removed dependency on `webdriver_manager.chrome.ChromeDriverManager`

**Files Modified**:
- `Dockerfile.tests` - Added `chromium-driver` installation
- `conftest.py` - Changed to use `/usr/bin/chromedriver` directly

---

### 2. **Port Mismatch in Environment Configuration**
**Problem**:
- `.env` files for `clientside` and `admin` were pointing to backend port 4000
- Docker Compose exposes backend on port 4001 (host port mapping: 4001:4000)
- Frontend applications couldn't communicate with backend

**Root Cause**:
```yaml
# docker-compose-part2.yml
ports:
  - "4001:4000"  # Host:Container mapping
```

**Solution**:
- Updated `clientside/.env`: Changed `VITE_BACKEND_URL=http://43.204.98.50:4000` → `http://43.204.98.50:4001`
- Updated `admin/.env`: Changed `VITE_BACKEND_URL=http://43.204.98.50:4000` → `http://43.204.98.50:4001`
- Backend `.env` port=4000 is correct (internal container port)

**Files Modified**:
- `clientside/.env`
- `admin/.env`

---

### 3. **Backend URL Configuration in conftest.py**
**Problem**:
- Test configuration file didn't have BACKEND_URL defined
- Only had BASE_URL and ADMIN_BASE_URL

**Solution**:
- Added `BACKEND_URL = "http://43.204.98.50:4001"` to conftest.py
- This ensures tests can make direct backend API calls if needed

**Files Modified**:
- `conftest.py`

---

## Configuration Overview

### Public EC2 Address Used
**IP Address**: `43.204.98.50`

### Port Mapping
```
Frontend (Vite React):     43.204.98.50:5174  (Host:5174 → Container:5173)
Backend (Node.js API):     43.204.98.50:4001  (Host:4001 → Container:4000)
Database (MongoDB):        Internal only      (No external access)
Admin (Vite React):        43.204.98.50:5174/admin
```

### Docker Compose Configuration (docker-compose-part2.yml)
```yaml
services:
  backend-dev:
    ports: ["4001:4000"]
    environment: (uses backend/.env with PORT=4000)
    
  client-dev:
    ports: ["5174:5173"]
    environment:
      VITE_BACKEND_URL=http://43.204.98.50:4001
    
  db:
    (Internal MongoDB, no external port)
```

### .env Files Configuration
**backend/.env**:
```
PORT=4000  (internal container port)
MONGODB_URI=mongodb+srv://...
JWT_SECRET=...
CLOUDINARY configs...
```

**clientside/.env** (UPDATED):
```
VITE_BACKEND_URL=http://43.204.98.50:4001
```

**admin/.env** (UPDATED):
```
VITE_BACKEND_URL=http://43.204.98.50:4001
```

---

## Test Configuration (conftest.py)

```python
BASE_URL = "http://43.204.98.50:5174"           # Main frontend
ADMIN_BASE_URL = "http://43.204.98.50:5174/admin"  # Admin portal
BACKEND_URL = "http://43.204.98.50:4001"        # Direct API access
```

---

## Jenkinsfile.part2 Environment Variables

```groovy
environment {
    DOCKER_IMAGE = "prescripto-tests:${BUILD_NUMBER}"
    TEST_RESULTS = "test-results-${BUILD_NUMBER}.xml"
    BACKEND_URL = "http://43.204.98.50:4001"
    FRONTEND_URL = "http://43.204.98.50:5174"
}
```

---

## Docker Test Environment

### Dockerfile.tests Changes
```dockerfile
# Now includes both chromium AND chromium-driver from same package source
RUN apt-get install -y chromium chromium-driver ...

# Uses system chromedriver directly
CMD ["pytest", "test_prescripto_e2e.py", "-v", "--tb=short"]
```

### Why This Works
- `apt-get` installs `chromium` and `chromium-driver` from official Debian repositories
- Both packages are always version-synchronized
- No need for `webdriver-manager` which downloads mismatched versions
- Direct `/usr/bin/chromedriver` path eliminates version lookup issues

---

## Verification Checklist

- [x] EC2 public IP (43.204.98.50) is consistent across all configs
- [x] Port 4001 is used for backend access from frontend
- [x] Port 5174 is used for frontend access
- [x] ChromeDriver version matches Chromium version
- [x] All .env files point to correct ports
- [x] conftest.py uses correct URLs with proper ports
- [x] docker-compose-part2.yml port mappings are correct
- [x] Jenkinsfile.part2 environment variables are aligned

---

## How to Test

Run the pipeline with these commands:

```bash
# Build test image
docker build -f Dockerfile.tests -t prescripto-tests:latest .

# Run tests
docker run --rm \
  --network host \
  -v /tmp/test-results:/app/test-results \
  prescripto-tests:latest \
  pytest test_prescripto_e2e.py -v

# Or via Jenkins
# Trigger Jenkinsfile.part2 pipeline
```

---

## Expected Behavior After Fixes

1. **Dockerfile builds successfully** with matching chromium & chromedriver
2. **conftest.py initializes WebDriver** without version conflicts
3. **Tests can reach frontend** at `43.204.98.50:5174`
4. **Frontend can reach backend** at `43.204.98.50:4001`
5. **All 24 test cases** should execute (may pass or fail based on app logic, but no setup errors)
6. **Test results** properly archived in Jenkins

---

## Additional Notes

- All URLs use the public EC2 address (43.204.98.50), NOT localhost
- No local development URLs present
- MongoDB connection is external (Atlas cluster)
- All sensitive credentials are in .env files (not committed to git)
- Tests run in headless mode with appropriate arguments for containerized execution
