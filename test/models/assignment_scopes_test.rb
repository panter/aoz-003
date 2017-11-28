require 'test_helper'
require 'utility/reminder_mailing_builder'

class AssignmentScopesTest < ActiveSupport::TestCase
  include ReminderMailingBuilder

  def setup
    @now = Time.zone.now
    [
      ['start_60_days_ago', @now.days_ago(60), nil, create(:client, :zuerich)],
      ['start_in_one_month', @now.next_month.end_of_month, nil],
      ['start_7_days_ago', @now.days_ago(7), nil],
      ['end_30_days_ago', @now.days_ago(60), @now.days_ago(30), create(:client, :zuerich)],
      ['end_15_days_ago', @now.days_ago(30), @now.days_ago(15)],
      ['end_future', @now.days_ago(5), @now.next_month.end_of_month, create(:client, :zuerich)]
    ].map { |parameters| make_assignment(*parameters) }
  end

  test 'no_end returns only with no end date set' do
    query = Assignment.no_end
    assert query.include? @start_60_days_ago
    assert query.include? @start_in_one_month
    assert query.include? @start_7_days_ago
    refute query.include? @end_30_days_ago
    refute query.include? @end_future
    assert_equal 3, query.count
  end

  test 'has_end returns only with end date set' do
    query = Assignment.has_end
    refute query.include? @start_60_days_ago
    refute query.include? @start_7_days_ago
    refute query.include? @start_in_one_month
    assert query.include? @end_30_days_ago
    assert query.include? @end_15_days_ago
    assert query.include? @end_future
    assert_equal 3, query.count
  end

  test 'end_in_past returns only with end_date in past' do
    query = Assignment.ended
    refute query.include? @start_60_days_ago
    refute query.include? @start_in_one_month
    refute query.include? @start_7_days_ago
    refute query.include? @end_future
    assert query.include? @end_30_days_ago
    assert query.include? @end_15_days_ago
    assert_equal 2, query.count
  end

  test 'end_before returns only ended before parameter' do
    query = Assignment.end_before(@now.days_ago(20))
    refute query.include? @start_60_days_ago
    refute query.include? @end_15_days_ago
    refute query.include? @end_future
    refute query.include? @start_7_days_ago
    refute query.include? @start_in_one_month
    assert query.include? @end_30_days_ago
    assert_equal 1, query.count
  end

  test 'end_after returns only ended after parameter' do
    query = Assignment.end_after(@now.days_ago(20))
    refute query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    refute query.include? @start_in_one_month
    assert query.include? @end_15_days_ago
    assert query.include? @end_future
    assert_equal 2, query.count
  end

  test 'end_within returns only ended between range' do
    query = Assignment.end_within(@now.days_ago(20)..@now.days_ago(10))
    refute query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    assert query.include? @end_15_days_ago
    refute query.include? @end_future
    assert_equal 1, query.count
  end

  test 'end_in_future returns only ending in the future' do
    query = Assignment.end_in_future
    refute query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    refute query.include? @end_15_days_ago
    assert query.include? @end_future
    assert_equal 1, query.count
  end

  test 'not_ended returns only with no ending or ending in future' do
    query = Assignment.not_ended
    assert query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    refute query.include? @end_15_days_ago
    assert query.include? @end_future
    assert_equal 4, query.count
  end

  test 'started returns only with start date in past' do
    query = Assignment.started
    assert query.include? @start_60_days_ago
    assert query.include? @end_30_days_ago
    assert query.include? @end_15_days_ago
    assert query.include? @end_future
    refute query.include? @start_in_one_month
    assert_equal 5, query.count
  end

  test 'start_before returns only with start date before given date' do
    query = Assignment.start_before(@now.days_ago(31))
    assert query.include? @start_60_days_ago
    assert query.include? @end_30_days_ago
    refute query.include? @end_15_days_ago
    refute query.include? @end_future
    refute query.include? @start_in_one_month
    assert_equal 2, query.count
  end

  test 'start_after returns only with start date after given date' do
    query = Assignment.start_after(@now.days_ago(29))
    refute query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    refute query.include? @end_15_days_ago
    assert query.include? @end_future
    assert query.include? @start_in_one_month
    assert_equal 3, query.count
  end

  test 'start_within returns only with start date after given date' do
    query = Assignment.start_within(@now.days_ago(32)..@now.days_ago(12))
    refute query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    assert query.include? @end_15_days_ago
    refute query.include? @end_future
    refute query.include? @start_in_one_month
    assert_equal 1, query.count
  end

  test 'active returns only started and not ended' do
    query = Assignment.active
    assert query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    refute query.include? @end_15_days_ago
    assert query.include? @end_future
    refute query.include? @start_in_one_month
    assert_equal 3, query.count
  end

  test 'inactive' do
    started_not_ended = make_assignment(nil, 20.days.ago)
    started_and_ended_past = make_assignment(nil, 100.days.ago, 50.days.ago)
    started_and_ends_in_future = make_assignment(nil, 100.days.ago, Time.zone.today + 20)
    no_start_and_end = make_assignment(nil)
    query = Assignment.inactive
    assert query.include? no_start_and_end
    assert query.include? started_and_ended_past
    refute query.include? started_and_ends_in_future
    refute query.include? started_not_ended
  end

  test 'active_between returns only started and not ended between start and end date' do
    started_before_not_ended = make_assignment(nil, 45.days.ago)
    started_before_end_within = make_assignment(nil, 45.days.ago, 25.days.ago)
    started_within_not_ended = make_assignment(nil, 30.days.ago)
    started_within_end_after = make_assignment(nil, 30.days.ago, 15.days.ago)
    started_after_no_end = make_assignment(nil, 15.days.ago)
    started_after_has_end = make_assignment(nil, 15.days.ago, 5.days.ago)
    started_before_ended_before = make_assignment(nil, 100.days.ago, 80.days.ago)
    no_start_and_end = make_assignment(nil)
    query = Assignment.active_between(40.days.ago, 20.days.ago)
    assert query.include? @start_60_days_ago
    assert query.include? @end_30_days_ago
    assert query.include? @end_15_days_ago
    assert query.include? started_before_not_ended
    assert query.include? started_before_end_within
    assert query.include? started_within_not_ended
    assert query.include? started_within_end_after
    refute query.include? started_after_no_end
    refute query.include? started_after_has_end
    refute query.include? started_before_ended_before
    refute query.include? no_start_and_end
    refute query.include? @end_future
    refute query.include? @start_in_one_month
    refute query.include? @start_7_days_ago
  end

  test 'will_start returns only assignments that will start in future' do
    query = Assignment.will_start
    refute query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    refute query.include? @end_15_days_ago
    refute query.include? @end_future
    assert query.include? @start_in_one_month
    refute query.include? @start_7_days_ago
    assert_equal 1, query.count
  end

  test 'created_between' do
    created_before = make_assignment(nil, 120.days.ago)
    created_after = make_assignment(nil, 40.days.ago)
    created_within = make_assignment(nil, 70.days.ago)
    query = Assignment.created_between(100.days.ago, 50.days.ago)
    assert query.include? created_within
    refute query.include? created_before
    refute query.include? created_after
  end

  test 'created_before' do
    created_before = make_assignment(nil, 120.days.ago)
    created_after = make_assignment(nil, 40.days.ago)
    query = Assignment.created_before(50.days.ago)
    assert query.include? created_before
    refute query.include? created_after
  end

  test 'created_after' do
    created_before = make_assignment(nil, 120.days.ago)
    created_after = make_assignment(nil, 40.days.ago)
    query = Assignment.created_after(50.days.ago)
    refute query.include? created_before
    assert query.include? created_after
  end

  test 'started_six_months_ago' do
    created_before = make_assignment(nil, 7.months.ago)
    created_after = make_assignment(nil, 2.months.ago)
    query = Assignment.started_six_months_ago
    assert query.include? created_before
    refute query.include? created_after
  end

  test 'zurich' do
    assignment_zurich = make_assignment(nil, nil, nil, create(:client_z))
    assignment_not_zurich = make_assignment(nil, nil, nil, create(:client))
    query = Assignment.zurich
    assert query.include? assignment_zurich
    refute query.include? assignment_not_zurich
  end

  test 'not_zurich' do
    assignment_zurich = make_assignment(nil, nil, nil, create(:client_z))
    assignment_not_zurich = make_assignment(nil, nil, nil, create(:client))
    query = Assignment.not_zurich
    refute query.include? assignment_zurich
    assert query.include? assignment_not_zurich
  end

  test 'internal' do
    assignment_internal = make_assignment(nil)
    assignment_internal.update(volunteer: create(:volunteer))
    assignment_external = make_assignment(nil)
    assignment_external.update(volunteer: create(:volunteer_external))
    query = Assignment.internal
    assert query.include? assignment_internal
    refute query.include? assignment_external
  end

  test 'external' do
    assignment_internal = make_assignment(nil)
    assignment_internal.update(volunteer: create(:volunteer))
    assignment_external = make_assignment(nil)
    assignment_external.update(volunteer: create(:volunteer_external))
    query = Assignment.external
    refute query.include? assignment_internal
    assert query.include? assignment_external
  end

  test 'started_ca_six_weeks_ago' do
    Assignment.with_deleted.map(&:really_destroy!)
    exactly_six_weeks = make_assignment(nil, 6.weeks.ago)
    seven_weeks_ago = make_assignment(nil, 7.weeks.ago)
    exactly_eight_weeks = make_assignment(nil, 8.weeks.ago)
    less_than_six_weeks = make_assignment(nil, 2.weeks.ago)
    more_than_8_weeks = make_assignment(nil, 2.years.ago)
    query = Assignment.started_ca_six_weeks_ago
    assert query.include? exactly_six_weeks
    assert query.include? seven_weeks_ago
    assert query.include? exactly_eight_weeks
    assert_not query.include? less_than_six_weeks
    assert_not query.include? more_than_8_weeks
  end

  def make_assignment(title, start_date = nil, end_date = nil, client = nil)
    assignment = create :assignment, period_start: start_date, period_end: end_date,
      client: client || create(:client)
    assignment.update(created_at: start_date) if start_date
    return assignment unless title
    instance_variable_set("@#{title}", assignment)
  end
end
