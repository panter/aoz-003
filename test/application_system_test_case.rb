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

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      active = page.evaluate_script('jQuery.active')
      active = page.evaluate_script('jQuery.active') until active.zero?
    end
  end

  def fill_autocomplete(name, options = {})
    find("[name=\"#{name}\"]").native.send_keys options[:with], :down
    wait_for_ajax
    items = page.find_all('li.ui-menu-item')
    if options[:items_expected]
      assert_equal options[:items_expected], items.size
    end
    if options[:check_items].present?
      items.each do |item|
        assert options[:check_items].include? item.text
      end
    end
    find("[name=\"#{name}\"]").native.send_keys :down, :enter
  end
end
