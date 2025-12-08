import pytest
from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager

# The base URL for the local Prescripto application
# NOTE: These URLs must point to the running application's host IP/DNS
BASE_URL = "http://43.204.98.50:5174"
ADMIN_BASE_URL = "http://43.204.98.50:5174/admin" # Ensure this path is correct

# Fixture to set up the WebDriver for all tests
@pytest.fixture(scope="module")
def driver():
    """
    Sets up and tears down the Selenium WebDriver using Headless Chrome.
    """
    print(f"\nSetting up Headless Chrome for tests.")
    
    # 1. Configure Chrome Options
    chrome_options = Options()
    
    # REQUIRED: Use headless mode for execution on AWS EC2/Jenkins
    chrome_options.add_argument("--headless=new") # Use 'new' headless mode for modern Chrome versions
    
    # Recommended arguments for containerized/headless execution
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--disable-gpu")
    
    # 2. Install and configure ChromeDriver
    try:
        # Use ChromeDriverManager to automatically handle the correct driver binary
        # It finds the compatible driver for the installed Chromium (v143)
        service = ChromeService(ChromeDriverManager().install())
        web_driver = webdriver.Chrome(service=service, options=chrome_options)
    except Exception as e:
        # Note: If this still fails, you may need to specify browser path in the options.
        print(f"Error setting up WebDriver: {e}")
        raise
    
    # 3. Setup Complete - Yield driver to the tests
    web_driver.implicitly_wait(10) # Wait up to 10 seconds for elements to appear
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
