require 'application_system_test_case'

class PerformanceReportsTest < ApplicationSystemTestCase
  setup do
    @user = create :user
    login_as @user
    visit performance_reports_path
  end

  test 'create new report' do
    two_years_ago = Time.zone.now.years_ago(2).year
    first(:link, 'Create new report').click
    click_link two_years_ago.to_s
    click_button 'Create Performance Report'
    assert page.has_text? 'Performance Report was successfully created.'
    assert page.has_text? "01.01.#{two_years_ago - 2000} 00:00"
    assert page.has_text? "31.12.#{two_years_ago - 2000} 23:59"
  end
end
