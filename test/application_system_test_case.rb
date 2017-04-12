require 'test_helper'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new app, inspector: true
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  screen_size = [1400, 1400]
  case ENV['driver']
  when 'chrome'
    driven_by :selenium, using: :chrome, screen_size: screen_size
  when 'poltergeist_debug'
    driven_by :poltergeist_debug, screen_size: screen_size
  else
    driven_by :poltergeist, screen_size: screen_size
  end
end
