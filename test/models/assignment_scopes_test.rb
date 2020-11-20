require 'test_helper'

class AssignmentScopesTest < ActiveSupport::TestCase
  def setup
    @now = Time.zone.today
    make_assignment(title: 'starts_today_no_end', start_date: @now)
    make_assignment(title: 'started_60_days_ago_no_end', start_date: @now.days_ago(60))
    make_assignment(title: 'starts_in_one_month_no_end', start_date: @now.next_month.end_of_month)
    make_assignment(title: 'started_7_days_ago_ends_in_2_months', start_date: @now.days_ago(7),
      end_date: @now.next_month.next_month)
    make_assignment(title: 'started_60_days_ago_ended_30_days_ago', start_date: @now.days_ago(60),
      end_date: @now.days_ago(30))
    make_assignment(title: 'started_30_days_ago_ended_15_days_ago', start_date: @now.days_ago(30),
      end_date: @now.days_ago(15))
    make_assignment(title: 'starts_tomorrow_ends_next_month', start_date: @now.tomorrow,
      end_date: @now.next_month)
    make_assignment(title: 'started_yesterday_ends_tomorrow', start_date: @now.yesterday,
      end_date: @now.tomorrow)
    make_assignment(title: 'no_start_ends_today', end_date: @now)
    make_assignment(title: 'no_start_ends_tomorrow', end_date: @now.tomorrow)
    make_assignment(title: 'no_start_no_end')
  end

  test 'no_end returns only with no end date set' do
    query = Assignment.no_end
    assert_includes query, @starts_today_no_end
    assert_includes query, @started_60_days_ago_no_end
    assert_includes query, @starts_in_one_month_no_end
    assert_includes query, @no_start_no_end
  end

  test 'has_end returns only with end date set' do
    query = Assignment.has_end
    assert_includes query, @started_7_days_ago_ends_in_2_months
    assert_includes query, @started_60_days_ago_ended_30_days_ago
    assert_includes query, @started_30_days_ago_ended_15_days_ago
    assert_includes query, @starts_tomorrow_ends_next_month
    assert_includes query, @started_yesterday_ends_tomorrow
    assert_includes query, @no_start_ends_today
    assert_includes query, @no_start_ends_tomorrow
  end

  test 'ended returns only with end_date in past or today' do
    query = Assignment.ended
    assert_includes query, @started_60_days_ago_ended_30_days_ago
    assert_includes query, @started_30_days_ago_ended_15_days_ago
    assert_includes query, @no_start_ends_today
  end

  test 'end_before returns only ended before parameter' do
    query = Assignment.end_before(@now)
    assert_includes query, @started_60_days_ago_ended_30_days_ago
    assert_includes query, @started_30_days_ago_ended_15_days_ago
  end

  test 'end_after returns only ended after parameter' do
    query = Assignment.end_after(@now)
    assert_includes query, @started_7_days_ago_ends_in_2_months
    assert_includes query, @starts_tomorrow_ends_next_month
    assert_includes query, @started_yesterday_ends_tomorrow
    assert_includes query, @no_start_ends_tomorrow
  end

  test 'end_within_returns_only_ended_between_range' do
    query = Assignment.end_within(@now.days_ago(10), @now.days_ago(20))
    assert_includes query, @started_30_days_ago_ended_15_days_ago
  end

  test 'end_in_future returns only ending in the future' do
    query = Assignment.end_in_future
    assert_includes query, @started_7_days_ago_ends_in_2_months
    assert_includes query, @starts_tomorrow_ends_next_month
    assert_includes query, @started_yesterday_ends_tomorrow
    assert_includes query, @no_start_ends_tomorrow
  end

  test 'not_ended returns only with no ending or ending in future' do
    query = Assignment.not_ended
    assert_includes query, @starts_today_no_end
    assert_includes query, @started_60_days_ago_no_end
    assert_includes query, @starts_in_one_month_no_end
    assert_includes query, @started_7_days_ago_ends_in_2_months
    assert_includes query, @starts_tomorrow_ends_next_month
    assert_includes query, @started_yesterday_ends_tomorrow
    assert_includes query, @no_start_ends_tomorrow
    assert_includes query, @no_start_no_end
  end

  test 'started returns only with start date in past or today' do
    query = Assignment.started
    assert_includes query, @starts_today_no_end
    assert_includes query, @started_60_days_ago_no_end
    assert_includes query, @started_7_days_ago_ends_in_2_months
    assert_includes query, @started_60_days_ago_ended_30_days_ago
    assert_includes query, @started_30_days_ago_ended_15_days_ago
    assert_includes query, @started_yesterday_ends_tomorrow
  end

  test 'start_before returns only with start date before given date' do
    query = Assignment.start_before(@now)
    assert_includes query, @started_60_days_ago_no_end
    assert_includes query, @started_7_days_ago_ends_in_2_months
    assert_includes query, @started_60_days_ago_ended_30_days_ago
    assert_includes query, @started_30_days_ago_ended_15_days_ago
    assert_includes query, @started_yesterday_ends_tomorrow
  end

  test 'start_after returns only with start date after given date' do
    query = Assignment.start_after(@now)
    assert_includes query, @starts_in_one_month_no_end
    assert_includes query, @starts_tomorrow_ends_next_month
  end

  test 'start_within returns only with start date after given date' do
    query = Assignment.start_within(@now.days_ago(12), @now.days_ago(32))
    assert_includes query, @started_30_days_ago_ended_15_days_ago
  end

  test 'active returns only started and not ended or not ended with no start date' do
    query = Assignment.active
    assert_includes query, @starts_today_no_end
    assert_includes query, @started_60_days_ago_no_end
    assert_includes query, @started_7_days_ago_ends_in_2_months
    assert_includes query, @started_yesterday_ends_tomorrow
    assert_includes query, @no_start_ends_tomorrow
  end

  test 'inactive returns not started, will start, ended, end today, without dates' do
    query = Assignment.inactive
    assert_includes query, @starts_in_one_month_no_end
    assert_includes query, @started_60_days_ago_ended_30_days_ago
    assert_includes query, @started_30_days_ago_ended_15_days_ago
    assert_includes query, @starts_tomorrow_ends_next_month
    assert_includes query, @no_start_ends_today
    assert_includes query, @no_start_no_end
  end

  test 'active_between returns only started and not ended between start and end date' do
    query = Assignment.active_between(70.days.ago, 5.days.ago)
    assert_includes query, @started_60_days_ago_no_end
    assert_includes query, @started_7_days_ago_ends_in_2_months
    assert_includes query, @started_60_days_ago_ended_30_days_ago
    assert_includes query, @started_30_days_ago_ended_15_days_ago
  end

  test 'will_start returns only assignments that will start in future' do
    query = Assignment.will_start
    assert_includes query, @starts_in_one_month_no_end
    assert_includes query, @starts_tomorrow_ends_next_month
  end

  test 'created_between' do
    created_before = make_assignment(start_date: 120.days.ago)
    created_after = make_assignment(start_date: 40.days.ago)
    created_within = make_assignment(start_date: 70.days.ago)
    query = Assignment.created_between(100.days.ago, 50.days.ago)
    assert_includes query, created_within
    refute_includes query, created_before
    refute_includes query, created_after
  end

  test 'created_before' do
    created_before = make_assignment(start_date: 120.days.ago)
    created_after = make_assignment(start_date: 40.days.ago)
    query = Assignment.created_before(50.days.ago)
    assert_includes query, created_before
    refute_includes query, created_after
  end

  test 'created_after' do
    created_before = make_assignment(start_date: 120.days.ago)
    created_after = make_assignment(start_date: 40.days.ago)
    query = Assignment.created_after(50.days.ago)
    refute_includes query, created_before
    assert_includes query, created_after
  end

  test 'zurich_not_zurich' do
    assignment_zurich = make_assignment(client: create(:client_z))
    zurich = Assignment.zurich
    not_zurich = Assignment.not_zurich
    assert_equal 1, zurich.count
    assert_includes zurich, assignment_zurich
    assert_equal 11, not_zurich.count
  end

  test 'internal_external' do
    assignment_external = make_assignment(volunteer: create(:volunteer, external: true))
    internal = Assignment.internal
    external = Assignment.external
    assert_equal 11, internal.count
    assert_includes external, assignment_external
    assert_equal 1, external.count
  end

  test 'started_ca_six_weeks_ago' do
    exactly_six_weeks = make_assignment(start_date: 6.weeks.ago)
    seven_weeks_ago = make_assignment(start_date: 7.weeks.ago)
    exactly_eight_weeks = make_assignment(start_date: 8.weeks.ago)
    less_than_six_weeks = make_assignment(start_date: 2.weeks.ago)
    more_than_8_weeks = make_assignment(start_date: 2.years.ago)
    query = Assignment.started_ca_six_weeks_ago
    assert_includes query, exactly_six_weeks
    assert_includes query, seven_weeks_ago
    assert_includes query, exactly_eight_weeks
    assert_not query.include? less_than_six_weeks
    assert_not query.include? more_than_8_weeks
  end
end
