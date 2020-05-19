require 'application_system_test_case'

class PerformanceReportsTest < ApplicationSystemTestCase
  include PerformanceReportGenerator

  setup do
    @user = create :user
    login_as @user
    visit performance_reports_path
  end

  test 'create new report' do
    two_years_ago = Time.zone.now.years_ago(2).year
    first(:link, 'Neuen Report erstellen').click
    click_link two_years_ago.to_s
    click_button 'Kennzahlen Report erfassen'
    assert page.has_text? 'Kennzahlen Report wurde erfolgreich erstellt.'
    assert page.has_text? "Kennzahlen des Kalenderjahrs #{two_years_ago}"
  end

  VALUE_ORDERS = {
    volunteers: [
      :created, :inactive, :resigned, :total,
      :active_assignment, :active_group_assignment, :only_assignment_active, :only_group_active,
      :active_both, :active_total,
      :assignment_hour_records, :assignment_hours, :group_offer_hour_records, :group_offer_hours,
      :total_hours,
      :assignment_feedbacks, :group_offer_feedbacks, :total_feedbacks
    ] + Event.kinds.keys.map(&:to_sym) + [:total_events],
    clients: [:created, :inactive, :resigned, :active_assignment, :total],
    assignments: [:created, :started, :active, :ended, :first_instruction_lessons, :all],
    group_offers_first: [:created, :created_assignments, :ended, :all,
                         :feedback_count],
    group_offers_second: [:total_created_assignments, :total_started_assignments,
                          :total_active_assignments, :total_ended_assignments,
                          :total_assignments]
  }.freeze

  test 'performance report data displayed' do
    main_setup_entities
    report_id, this_year_report = PerformanceReport.create!(
      user: @user, period_start: @today.beginning_of_year, period_end: @today.end_of_year
    ).slice(:id, :report_content).values

    visit performance_report_path(report_id)
    volunteers, clients, assignments, group_offers = this_year_report.values_at('volunteers',
                                                                                'clients',
                                                                                'assignments',
                                                                                'group_offers')

    # Volunteers section
    column_order = ['zurich', 'not_zurich', 'internal', 'external', 'all']
    VALUE_ORDERS[:volunteers].each do |value_key|
      within "tr[data-key=\"#{value_key}\"][data-group=\"volunteers\"]" do
        assert_css 'td.name', text: I18n.t("performance_reports.values_volunteers.#{value_key}")
        column_order.each do |category_key|
          assert_css "td[data-category=\"#{category_key}\"]",
                     text: volunteers[category_key][value_key.to_s]
        end
      end
    end

    # Clients section
    column_order = ['zurich', 'not_zurich', 'all']
    VALUE_ORDERS[:clients].each do |value_key|
      within "tr[data-key=\"#{value_key}\"][data-group=\"clients\"]" do
        assert_css 'td.name', text: I18n.t("performance_reports.values_clients.#{value_key}")
        column_order.each do |category_key|
          assert_css "td[data-category=\"#{category_key}\"]",
                     text: clients[category_key][value_key.to_s]
        end
      end
    end

    # Assignment section
    column_order = ['zurich', 'not_zurich', 'all']
    VALUE_ORDERS[:assignments].each do |value_key|
      within "tr[data-key=\"#{value_key}\"][data-group=\"assignments\"]" do
        assert_css 'td.name', text: I18n.t("performance_reports.values_assignments.#{value_key}")
        column_order.each do |category_key|
          assert_css "td[data-category=\"#{category_key}\"]",
                     text: assignments[category_key][value_key.to_s]
        end
      end
    end

    # Group Offer section
    column_order = ['internal', 'external', 'all']
    (VALUE_ORDERS[:group_offers_first] + VALUE_ORDERS[:group_offers_second]).each do |value_key|
      within "tr[data-key=\"#{value_key}\"][data-group=\"group_offers\"]" do
        assert_css 'td.name', text: I18n.t("performance_reports.values_group_offers.#{value_key}")
        column_order.each do |category_key|
          assert_css "td[data-category=\"#{category_key}\"]",
                     text: group_offers[category_key][value_key.to_s]
        end
      end
    end
  end
end
