import pytest
from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.chrome.options import Options

# The base URL for the local Prescripto application
BASE_URL = "http://43.204.98.50:5174"
ADMIN_BASE_URL = "http://43.204.98.50:5174/admin"
BACKEND_URL = "http://43.204.98.50:4001"

# Fixture to set up the WebDriver for all tests
@pytest.fixture(scope="module")
def driver():
    """
    Sets up and tears down the Selenium WebDriver using Headless Chrome.
    """
    print(f"\nSetting up Headless Chrome for tests.")
    
    # 1. Configure Chrome Options
    chrome_options = Options()
    
    # Set the binary path for Chromium
    chrome_options.binary_location = '/usr/bin/chromium'
    
    # Use 'new' headless mode for modern Chrome versions
    chrome_options.add_argument("--headless=new")
    
    # Recommended arguments for containerized/headless execution
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--disable-gpu")
    
    # 2. Use system chromedriver directly (installed via chromium-driver package)
    try:
        service = ChromeService('/usr/bin/chromedriver')
        web_driver = webdriver.Chrome(service=service, options=chrome_options)
    except Exception as e:
        print(f"Error setting up WebDriver: {e}")
        raise
    
    # 3. Setup Complete - Yield driver to the tests
    web_driver.implicitly_wait(10) 
    yield web_driver
    
    # 4. Teardown - Runs after all tests are complete
    print("\nQuitting WebDriver...")
    web_driver.quit()

@pytest.fixture(scope="module")
def base_url():
    """Provides the application URL to the test module."""
    return BASE_URL

@pytest.fixture(scope="module")
def admin_base_url():
    """Provides the admin application URL to the test module."""
    return ADMIN_BASE_URL

