require 'headless'
require 'selenium-webdriver'

class Crawler    
    def initialize
        headless = Headless.new
        headless.start
        
        profile = Selenium::WebDriver::Firefox::Profile.new
        profile['general.useragent.override'] = 'Mozilla/5.0(iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B314 Safari/531.21.10'
        @driver = Selenium::WebDriver.for :firefox, :profile => profile
    end    
    
    def get(url)
        @driver.navigate.to(url)
        @driver.page_source
    end
end
