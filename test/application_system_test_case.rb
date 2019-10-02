require 'test_helper'
require 'selenium/webdriver'

Capybara.register_driver :chrome_headless do |app|
  chrome_options = {
    chromeOptions: { args: %w[headless disable-gpu no-sandbox window-size=1600x2000], w3c: false }
  }
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(chrome_options)
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara.register_driver :visible_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :rack do |app|
  Capybara::RackTest::Driver.new(app, headers: { 'HTTP_USER_AGENT' => 'Capybara' })
end

def driver_selected_by_env_var
  if ENV['driver'] == 'visible'
    :visible_chrome
  else
    :chrome_headless
  end
end

Capybara.configure do |config|
  config.default_driver = driver_selected_by_env_var
  config.default_max_wait_time = 5
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include ReminderMailingBuilder
  include GroupOfferAndAssignment

  driven_by driver_selected_by_env_var

  def use_rack_driver
    Capybara.current_driver = :rack
  end

  def use_default_driver
    Capybara.use_default_driver
  end

  def teardown
    use_default_driver
  end

  def match_polymorph_path(polymorphic_param, wildcard_start: nil, wildcard_end: true)
    if wildcard_start
      { href: /.*#{polymorphic_path(polymorphic_param)}.*/x }
    elsif wildcard_end
      { href: /#{polymorphic_path(polymorphic_param)}.*/x }
    else
      { href: /#{polymorphic_path(polymorphic_param)}/x }
    end
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
      loop until page.evaluate_script('jQuery.active').zero?
    end
  end

  def fill_field_char_by_char_and_wait_for_ajax(locator, text)
    field = page.find_field(locator)
    text.split('').each do |char|
      field.native.send_keys(char)
      wait_for_ajax
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

  def selectize_fill(field, value)
    # fill in the input field
    page.find(".#{field} div.selectize-input input").set(value)
  end

  def selectize_select(field, value)
    selectize_fill(field, value)
    # select the first dropdown item with given value
    page.find(".#{field} div.selectize-dropdown-content .option", text: value).click
  end

  def dom_id(record)
    ActionView::RecordIdentifier.dom_id record
  end
end
