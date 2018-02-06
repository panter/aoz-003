require 'test_helper'
require 'ostruct'
require 'utility/performance_report_generator'

class GroupOfferCategoryTest < ActiveSupport::TestCase
  include PerformanceReportGenerator

  def setup
    DatabaseCleaner.clean
    DatabaseCleaner.start

    really_destroy_with_deleted(Hour, Feedback, TrialFeedback, Assignment, Client, GroupAssignment,
      GroupOffer, Department, User)
    @today = Time.zone.today
    @this_periods = [@today.beginning_of_year, @today.end_of_year]
    @year_ago = 1.year.ago.to_date
    @last_periods = [@year_ago.beginning_of_year, @year_ago.end_of_year]
    @user = create :user

    @this_year = PerformanceReport.create!(user: @user, period_start: @this_periods.first,
      period_end: @this_periods.last)
    @last_year = PerformanceReport.create!(user: @user, period_start: @last_periods.first,
      period_end: @last_periods.last)
  end

  def type_of_values(content)
    content.values.map(&:values).flatten.map(&:values).flatten.uniq
  end

  test 'no_nothing_reports_have_all_zero_values' do
    assert_equal([0], type_of_values(@this_year.report_content))
    assert_equal([0], type_of_values(@last_year.report_content))
  end

  VOLUNTEER_ZERO = {
    total: 0,
    active_assignment: 0,
    active_group_assignment: 0,
    active_both: 0,
    active_total: 0,
    only_assignment_active: 0,
    only_group_active: 0,
    created: 0,
    resigned: 0,
    inactive: 0,
    assignment_hour_records: 0,
    assignment_hours: 0,
    group_offer_hour_records: 0,
    group_offer_hours: 0,
    total_hour_records: 0,
    total_hours: 0,
    assignment_feedbacks: 0,
    group_offer_feedbacks: 0,
    total_feedbacks: 0,
    assignment_trial_feedbacks: 0,
    group_offer_trial_feedbacks: 0,
    total_trial_feedbacks: 0
  }.stringify_keys.freeze

  test 'volunteer_zurich_internal_external' do
    volunteer_zurich_this_year = create :volunteer_with_user, :zuerich
    volunteer_zurich_this_year.update(created_at: @this_periods.first)

    # Last year still all zero
    @last_year.generate_report
    assert_equal([0], type_of_values(@last_year.report_content))

    # this year 0 and 1
    @this_year.generate_report
    assert_equal([0, 1], type_of_values(@this_year.report_content).sort)

    expected_influenced = VOLUNTEER_ZERO.merge(
      total: 1, created: 1, inactive: 1
    ).stringify_keys

    assert_equal(expected_influenced, @this_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['zurich'])
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['internal'])

    assert_equal([0], @this_year.report_content['volunteers']['not_zurich'].values.uniq)
    assert_equal([0], @this_year.report_content['volunteers']['external'].values.uniq)

    volunteer_zurich_this_year.update(external: true)
    @this_year.generate_report
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['zurich'])
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['external'])

    assert_equal([0], @this_year.report_content['volunteers']['not_zurich'].values.uniq)
    assert_equal([0], @this_year.report_content['volunteers']['internal'].values.uniq)

    volunteer_zurich_this_year.update(external: false)
    volunteer_zurich_this_year.contact.update(postal_code: 3000, city: 'Bern')
    @this_year.generate_report
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['not_zurich'])
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['internal'])

    assert_equal([0], @this_year.report_content['volunteers']['zurich'].values.uniq)
    assert_equal([0], @this_year.report_content['volunteers']['external'].values.uniq)
  end

  test 'volunteer_active_inactive' do
    volunteer_zurich_this_year = create :volunteer_with_user, :zuerich
    volunteer_zurich_this_year.update(created_at: @this_periods.first.to_date + 2)
    volunteer_zurich_last_year = create :volunteer_with_user, :zuerich
    volunteer_zurich_last_year.update(created_at: @last_periods.first.to_date + 10)

    @this_year.generate_report
    assert_equal([0, 1, 2], type_of_values(@this_year.report_content).sort)
    @last_year.generate_report
    assert_equal([0, 1], type_of_values(@last_year.report_content).sort)

    expected_influenced_last_year = VOLUNTEER_ZERO.merge(
      total: 1, created: 1, inactive: 1
    ).stringify_keys

    expected_influenced_this_year = VOLUNTEER_ZERO.merge(
      total: 2, created: 1, inactive: 2
    ).stringify_keys

    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['zurich'])
    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['internal'])
    assert_equal([0], @this_year.report_content['volunteers']['not_zurich'].values.uniq)
    assert_equal([0], @this_year.report_content['volunteers']['external'].values.uniq)

    assert_equal(expected_influenced_last_year, @last_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced_last_year, @last_year.report_content['volunteers']['zurich'])
    assert_equal(expected_influenced_last_year, @last_year.report_content['volunteers']['internal'])
    assert_equal([0], @last_year.report_content['volunteers']['not_zurich'].values.uniq)
    assert_equal([0], @last_year.report_content['volunteers']['external'].values.uniq)

    create(:assignment, volunteer: volunteer_zurich_this_year, period_start: 2.days.ago,
      period_end: nil)

    @this_year.generate_report

    expected_influenced_this_year.merge!(
      active_assignment: 1, active_total: 1, only_assignment_active: 1, inactive: 1
    ).stringify_keys!

    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['all'])

    volunteer_zurich_this_year2 = create :volunteer_with_user, :zuerich
    volunteer_zurich_this_year2.update(created_at: @this_periods.first.to_date + 2)
    create(:group_assignment, volunteer: volunteer_zurich_this_year2, period_start: 2.days.ago,
      period_end: nil)

    expected_influenced_this_year.merge!(
      total: 3, active_group_assignment: 1, active_total: 2, only_group_active: 1, created: 2
    ).stringify_keys!
    @this_year.generate_report

    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['all'])

    group_assignment_zh_this_year = create(:group_assignment, volunteer: volunteer_zurich_this_year,
      period_start: @this_periods.first, period_end: nil)
    last_year_assignment = create(:assignment, volunteer: volunteer_zurich_last_year,
      period_start: 1.year.ago, period_end: nil)

    expected_influenced_this_year.merge!(
      active_assignment: 2, active_group_assignment: 2, active_total: 3, active_both: 1, inactive: 0
    ).stringify_keys!
    expected_influenced_last_year.merge!(
      active_assignment: 1, active_total: 1, only_assignment_active: 1, inactive: 0
    ).stringify_keys!
    @this_year.generate_report
    @last_year.generate_report

    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced_last_year, @last_year.report_content['volunteers']['all'])

    group_assignment_zh_this_year.update(period_end: 2.days.ago)
    last_year_assignment.update(period_end: @last_periods.last.to_date - 20)

    expected_influenced_this_year.merge!(
      active_assignment: 1, active_group_assignment: 2, active_total: 2, active_both: 1,
      inactive: 1, only_assignment_active: 0
    ).stringify_keys!
    @this_year.generate_report
    @last_year.generate_report

    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced_last_year, @last_year.report_content['volunteers']['all'])
  end
end
