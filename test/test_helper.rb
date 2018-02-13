# frozen_string_literal: true

# Test helpers
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)

# Basic coverage statistics from [SimpleCov](https://github.com/colszowka/simplecov)
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
)

SimpleCov.start('rails') do
  add_filter '/test/'
end

require 'rails/test_help'
require 'minitest/rails'

require 'logger'
require 'minitest/reporters'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'byebug'
require 'capybara/minitest'
require 'capybara/minitest/spec'
require 'capybara/rails'
require 'selenium/webdriver'

Minitest.backtrace_filter = Minitest::ExtensibleBacktraceFilter.new
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# Register a driver for visible Chrome using Selenium
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

# Register a driver for headless Chrome using Selenium
Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless no-sandbox] },
    loggingPrefs: { browser: 'ALL' }
  )

  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities)
end

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, headers: { 'HTTP_USER_AGENT' => 'Capybara' })
end

# To see the Chrome window while tests are running, set this var to true
see_visible_window_while_test_run = ENV['TEST_BROWSER_VISIBLE']
driver = see_visible_window_while_test_run ? :chrome : :headless_chrome
Capybara.default_driver    = driver
Capybara.javascript_driver = driver

# VCR Setup
VCR.configure do |config|
  config.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true

  # re-record every 7 days, but only if we're running in development not CI
  c.default_cassette_options = { re_record_interval: 7.days } if Rails.env.development?
end

module ActiveSupport
  # Set up fixtures and such
  class TestCase
    self.file_fixture_path = 'test/fixtures/files'
  end
end
