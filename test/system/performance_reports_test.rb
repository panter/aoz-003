require 'application_system_test_case'
require 'utility/performance_report_generator'

class PerformanceReportsTest < ApplicationSystemTestCase
  include PerformanceReportGenerator

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
    assert page.has_text? "Performance report of the calendar year #{two_years_ago}"
  end

  test 'performance report data displayed' do
    main_setup_entities
    report_id, this_year_report = PerformanceReport.create!(
      user: @user, period_start: @today.beginning_of_year, period_end: @today.end_of_year
    ).slice(:id, :report_content).values

    visit performance_report_path(report_id)

    assert page.has_text? 'Global'
    assert page.has_text? "Total number of volunteers	#{this_year_report['global']['volunteers']['total']}"
    assert page.has_text? "Number of new volunteers	#{this_year_report['global']['volunteers']['new']}"
    assert page.has_text? "Total active volunteers by the end of the period	#{this_year_report['global']['volunteers']['active']}"

    assert page.has_text? "Total number of clients	#{this_year_report['global']['clients']['total']}"
    assert page.has_text? "Number of new clients	#{this_year_report['global']['clients']['new']}"
    assert page.has_text? "Total number of active clients by the end of the period	   #{this_year_report['global']['clients']['active']}"

    assert page.has_text? "Total number of assignments	#{this_year_report['global']['assignments']['total']}"
    assert page.has_text? "Number of new assignments	#{this_year_report['global']['assignments']['new']}"
    assert page.has_text? "Number of finished assignments	#{this_year_report['global']['assignments']['ended']}"
    assert page.has_text? "Total number of active assignments by the end of the period #{this_year_report['global']['assignments']['active']}"


    assert page.has_text? "Zuerich"
    assert page.has_text? "Total number of volunteers	#{this_year_report['zuerich']['volunteers']['total']}"
    assert page.has_text? "Number of new volunteers	#{this_year_report['zuerich']['volunteers']['new']}"
    assert page.has_text? "Number of resigned volunteers"
    assert page.has_text? "Total active volunteers by the end of the period	#{this_year_report['zuerich']['volunteers']['active']}"

    assert page.has_text? "Total number of clients	#{this_year_report['zuerich']['clients']['total']}"
    assert page.has_text? "Number of new clients	#{this_year_report['zuerich']['clients']['new']}"
    assert page.has_text? "Number of finished clients"
    assert page.has_text? "Total number of active clients by the end of the period	#{this_year_report['zuerich']['clients']['active']}"

    assert page.has_text? "Total number of assigned clients	#{this_year_report['zuerich']['assignments']['total']}"
    assert page.has_text? "Number of new assignments	#{this_year_report['zuerich']['assignments']['new']}"
    assert page.has_text? "Number of finished assignments	#{this_year_report['zuerich']['assignments']['ended']}"
    assert page.has_text? "Total number of active assignments by the end of the period	#{this_year_report['zuerich']['assignments']['active']}"

    assert page.has_text? "Group offers"
    assert page.has_text? "Total number of groups (Courses, Animations, Others)	#{this_year_report['group_offers']['total']}"
    assert page.has_text? "Number of new groups (Courses, Animations, Others)	#{this_year_report['group_offers']['new']}"
    assert page.has_text? "Number of finished groups (Courses, Animations, Others)	#{this_year_report['group_offers']['ended']}"
    assert page.has_text? "Total number of active groups by the end of the period	#{this_year_report['group_offers']['active']}"
  end
end
