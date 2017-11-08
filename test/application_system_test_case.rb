require 'test_helper'

DIMENSIONS = [1800, 4000].freeze

Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    phantomjs: Phantomjs.path,
    inspector: true,
    screen_size: DIMENSIONS,
    window_size: DIMENSIONS
  )
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    phantomjs: Phantomjs.path,
    screen_size: DIMENSIONS,
    window_size: DIMENSIONS
  )
end

def driven_by_default(driver = :poltergeist, using: nil)
  driven_by driver, using: using, screen_size: DIMENSIONS
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

  def scroll_to_element(element)
    script = <<-JS
      arguments[0].scrollIntoView(true);
    JS
    page.execute_script(script, element.native)
  end

  def scroll_table_right
    page.driver.scroll_to(1000, 0)
  end

  def select_date(selects, *values)
    selects[0].select values[0]
    selects[1].select values[1]
    selects[2].select values[2]
  end
end
