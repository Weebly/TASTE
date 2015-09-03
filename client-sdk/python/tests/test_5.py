import unittest
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from taste import *
import sys

class TestStringMethods(unittest.TestCase):

  def setUp(self):
      self.taste = taste('http://192.168.59.103:3000')
      options = {
        'test_name': self._testMethodName,
        'platform': 'Windows 7',
        'browser': 'chrome'
      }
      desired_capabilities = DesiredCapabilities.CHROME
      desired_capabilities['applicationName'] = self.taste.request_run(options)

      self.driver = webdriver.Remote(
      command_executor='http://192.168.59.103:4444/wd/hub',
      desired_capabilities=desired_capabilities)

  def test_get_page(self):
      self.driver.get('http://www.google.com/')
      search_input = self.driver.find_element_by_css_selector('input[title=Search]')
      search_input.send_keys('search for something\n')

  def tearDown(self):
      self.driver.quit()
      status = (sys.exc_info() == (None, None, None))
      self.taste.update_test_result(status)

if __name__ == '__main__':
    unittest.main()
