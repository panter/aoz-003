require 'test_helper'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new app, inspector: true
end

def driven_by_default(driver = :poltergeist, using: nil, screen_size: [1400, 1400])
  driven_by driver, using: using, screen_size: screen_size
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  case ENV['driver']
  when 'chrome'
    driven_by_default :selenium, using: :chrome
  when 'poltergeist_debug'
    driven_by_default :poltergeist_debug
  else
    driven_by_default
  end
end
