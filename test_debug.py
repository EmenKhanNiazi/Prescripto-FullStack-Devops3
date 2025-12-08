import pytest
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

# Simple debug test to understand page structure
def test_homepage_structure(driver, base_url):
    """Inspect the actual homepage structure."""
    driver.get(base_url)
    time.sleep(3)  # Wait for page to fully load
    
    print(f"\n\n=== PAGE INFO ===")
    print(f"URL: {driver.current_url}")
    print(f"Title: {driver.title}")
    
    # Get all text from page
    body_text = driver.find_element(By.TAG_NAME, "body").text
    print(f"\n=== BODY TEXT (first 500 chars) ===\n{body_text[:500]}")
    
    # Look for buttons
    buttons = driver.find_elements(By.TAG_NAME, "button")
    print(f"\n=== BUTTONS FOUND ({len(buttons)}) ===")
    for i, btn in enumerate(buttons[:10]):
        print(f"Button {i}: '{btn.text}' (visible: {btn.is_displayed()})")
    
    # Look for links
    links = driver.find_elements(By.TAG_NAME, "a")
    print(f"\n=== LINKS FOUND ({len(links)}) ===")
    for i, link in enumerate(links[:10]):
        print(f"Link {i}: '{link.text}' -> {link.get_attribute('href')}")
    
    # Look for headings
    headings = driver.find_elements(By.TAG_NAME, "h1")
    print(f"\n=== H1 HEADINGS ({len(headings)}) ===")
    for i, h in enumerate(headings):
        print(f"H1 {i}: '{h.text}'")
    
    # Screenshot for visual inspection
    driver.save_screenshot("homepage.png")
    print(f"\nScreenshot saved: homepage.png")
    
    assert True  # Just pass to see the debug output
