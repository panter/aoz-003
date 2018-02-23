require 'test_helper'
require 'selenium/webdriver'
require 'utility/reminder_mailing_builder'
require 'utility/group_offer_and_assignment'


Capybara.register_driver(:headless_chrome) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless disable-gpu no-sandbox] }
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.register_driver(:visible_chrome) do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include ReminderMailingBuilder
  include GroupOfferAndAssignment

  case ENV['driver']
  when 'visible'
    driven_by :visible_chrome
  else
    driven_by :headless_chrome
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

  def any_checked?(selector)
    page.find_all(selector).any?(&:checked?)
  end

  def all_checked?(selector)
    page.find_all(selector).all?(&:checked?)
  end
end
