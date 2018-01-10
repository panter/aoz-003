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
    assert query.include? @starts_today_no_end
    assert query.include? @started_60_days_ago_no_end
    assert query.include? @starts_in_one_month_no_end
    assert query.include? @no_start_no_end
    assert_equal 4, query.count
  end

  test 'has_end returns only with end date set' do
    query = Assignment.has_end
    assert query.include? @started_7_days_ago_ends_in_2_months
    assert query.include? @started_60_days_ago_ended_30_days_ago
    assert query.include? @started_30_days_ago_ended_15_days_ago
    assert query.include? @starts_tomorrow_ends_next_month
    assert query.include? @started_yesterday_ends_tomorrow
    assert query.include? @no_start_ends_today
    assert query.include? @no_start_ends_tomorrow
    assert_equal 7, query.count
  end

  test 'ended returns only with end_date in past or today' do
    query = Assignment.ended
    assert query.include? @started_60_days_ago_ended_30_days_ago
    assert query.include? @started_30_days_ago_ended_15_days_ago
    assert query.include? @no_start_ends_today
    assert_equal 3, query.count
  end

  test 'end_before returns only ended before parameter' do
    query = Assignment.end_before(@now)
    assert query.include? @started_60_days_ago_ended_30_days_ago
    assert query.include? @started_30_days_ago_ended_15_days_ago
    assert_equal 2, query.count
  end

  test 'end_after returns only ended after parameter' do
    query = Assignment.end_after(@now)
    assert query.include? @started_7_days_ago_ends_in_2_months
    assert query.include? @starts_tomorrow_ends_next_month
    assert query.include? @started_yesterday_ends_tomorrow
    assert query.include? @no_start_ends_tomorrow
    assert_equal 4, query.count
  end

  test 'end_within returns only ended between range' do
    query = Assignment.end_within(@now.days_ago(20)..@now.days_ago(10))
    assert query.include? @started_30_days_ago_ended_15_days_ago
    assert_equal 1, query.count
  end

  test 'end_in_future returns only ending in the future' do
    query = Assignment.end_in_future
    assert query.include? @started_7_days_ago_ends_in_2_months
    assert query.include? @starts_tomorrow_ends_next_month
    assert query.include? @started_yesterday_ends_tomorrow
    assert query.include? @no_start_ends_tomorrow
    assert_equal 4, query.count
  end

  test 'not_ended returns only with no ending or ending in future' do
    query = Assignment.not_ended
    assert query.include? @starts_today_no_end
    assert query.include? @started_60_days_ago_no_end
    assert query.include? @starts_in_one_month_no_end
    assert query.include? @started_7_days_ago_ends_in_2_months
    assert query.include? @starts_tomorrow_ends_next_month
    assert query.include? @started_yesterday_ends_tomorrow
    assert query.include? @no_start_ends_tomorrow
    assert query.include? @no_start_no_end
    assert_equal 8, query.count
  end

  test 'started returns only with start date in past or today' do
    query = Assignment.started
    assert query.include? @starts_today_no_end
    assert query.include? @started_60_days_ago_no_end
    assert query.include? @started_7_days_ago_ends_in_2_months
    assert query.include? @started_60_days_ago_ended_30_days_ago
    assert query.include? @started_30_days_ago_ended_15_days_ago
    assert query.include? @started_yesterday_ends_tomorrow
    assert_equal 6, query.count
  end

  test 'start_before returns only with start date before given date' do
    query = Assignment.start_before(@now)
    assert query.include? @started_60_days_ago_no_end
    assert query.include? @started_7_days_ago_ends_in_2_months
    assert query.include? @started_60_days_ago_ended_30_days_ago
    assert query.include? @started_30_days_ago_ended_15_days_ago
    assert query.include? @started_yesterday_ends_tomorrow
    assert_equal 5, query.count
  end

  test 'start_after returns only with start date after given date' do
    query = Assignment.start_after(@now)
    assert query.include? @starts_in_one_month_no_end
    assert query.include? @starts_tomorrow_ends_next_month
    assert_equal 2, query.count
  end

  test 'start_within returns only with start date after given date' do
    query = Assignment.start_within(@now.days_ago(32)..@now.days_ago(12))
    assert query.include? @started_30_days_ago_ended_15_days_ago
    assert_equal 1, query.count
  end

  test 'active returns only started and not ended or not ended with no start date' do
    query = Assignment.active
    assert query.include? @starts_today_no_end
    assert query.include? @started_60_days_ago_no_end
    assert query.include? @started_7_days_ago_ends_in_2_months
    assert query.include? @started_yesterday_ends_tomorrow
    assert query.include? @no_start_ends_tomorrow
    assert_equal 5, query.count
  end

  test 'inactive returns not started, will start, ended, end today, without dates' do
    query = Assignment.inactive
    assert query.include? @starts_in_one_month_no_end
    assert query.include? @started_60_days_ago_ended_30_days_ago
    assert query.include? @started_30_days_ago_ended_15_days_ago
    assert query.include? @starts_tomorrow_ends_next_month
    assert query.include? @no_start_ends_today
    assert query.include? @no_start_no_end
    assert_equal 6, query.count
  end

  test 'active_between returns only started and not ended between start and end date' do
    query = Assignment.active_between(70.days.ago, 5.days.ago)
    assert query.include? @started_60_days_ago_no_end
    assert query.include? @started_7_days_ago_ends_in_2_months
    assert query.include? @started_60_days_ago_ended_30_days_ago
    assert query.include? @started_30_days_ago_ended_15_days_ago
    assert_equal 4, query.count
  end

  test 'will_start returns only assignments that will start in future' do
    query = Assignment.will_start
    assert query.include? @starts_in_one_month_no_end
    assert query.include? @starts_tomorrow_ends_next_month
    assert_equal 2, query.count
  end

  test 'created_between' do
    created_before = make_assignment(start_date: 120.days.ago)
    created_after = make_assignment(start_date: 40.days.ago)
    created_within = make_assignment(start_date: 70.days.ago)
    query = Assignment.created_between(100.days.ago, 50.days.ago)
    assert query.include? created_within
    refute query.include? created_before
    refute query.include? created_after
  end

  test 'created_before' do
    created_before = make_assignment(start_date: 120.days.ago)
    created_after = make_assignment(start_date: 40.days.ago)
    query = Assignment.created_before(50.days.ago)
    assert query.include? created_before
    refute query.include? created_after
  end

  test 'created_after' do
    created_before = make_assignment(start_date: 120.days.ago)
    created_after = make_assignment(start_date: 40.days.ago)
    query = Assignment.created_after(50.days.ago)
    refute query.include? created_before
    assert query.include? created_after
  end

  test 'started_six_months_ago' do
    created_before = make_assignment(start_date: 7.months.ago)
    created_after = make_assignment(start_date: 2.months.ago)
    query = Assignment.started_six_months_ago
    assert query.include? created_before
    refute query.include? created_after
  end

  test 'zurich_not_zurich' do
    assignment_zurich = make_assignment(client: create(:client_z))
    zurich = Assignment.zurich
    not_zurich = Assignment.not_zurich
    assert_equal 1, zurich.count
    assert zurich.include? assignment_zurich
    assert_equal 11, not_zurich.count
  end

  test 'internal_external' do
    assignment_external = make_assignment(volunteer: create(:volunteer_external))
    internal = Assignment.internal
    external = Assignment.external
    assert_equal 11, internal.count
    assert external.include? assignment_external
    assert_equal 1, external.count
  end

  test 'started_ca_six_weeks_ago' do
    destroy_really_all(Assignment)
    exactly_six_weeks = make_assignment(start_date: 6.weeks.ago)
    seven_weeks_ago = make_assignment(start_date: 7.weeks.ago)
    exactly_eight_weeks = make_assignment(start_date: 8.weeks.ago)
    less_than_six_weeks = make_assignment(start_date: 2.weeks.ago)
    more_than_8_weeks = make_assignment(start_date: 2.years.ago)
    query = Assignment.started_ca_six_weeks_ago
    assert query.include? exactly_six_weeks
    assert query.include? seven_weeks_ago
    assert query.include? exactly_eight_weeks
    assert_not query.include? less_than_six_weeks
    assert_not query.include? more_than_8_weeks
  end

  test 'no_reminder_mailing' do
    destroy_really_all(Assignment)
    without_reminder_mailing = make_assignment(start_date: 7.weeks.ago)
    with_reminder_mailing = make_assignment(start_date: 7.weeks.ago)
    create_probation_mailing(with_reminder_mailing)
    query = Assignment.no_reminder_mailing
    assert query.include? without_reminder_mailing
    assert_not query.include? with_reminder_mailing
  end

  test 'need_trial_period_reminder_mailing' do
    destroy_really_all(Assignment)
    exactly_six_weeks = make_assignment(start_date: 6.weeks.ago)
    exactly_six_weeks_mailed = make_assignment(start_date: 6.weeks.ago)
    seven_weeks_ago = make_assignment(start_date: 7.weeks.ago)
    seven_weeks_ago_mailed = make_assignment(start_date: 7.weeks.ago)
    create_probation_mailing(seven_weeks_ago_mailed, exactly_six_weeks_mailed)
    query = Assignment.need_trial_period_reminder_mailing
    assert query.include? exactly_six_weeks
    assert query.include? seven_weeks_ago
    assert_not query.include? seven_weeks_ago_mailed
    assert_not query.include? exactly_six_weeks_mailed
  end

  test 'with_half_year_reminder_mailing' do
    with_probation_mailing = make_assignment(start_date: 7.weeks.ago)
    create_probation_mailing(with_probation_mailing)
    with_half_year_mailing = make_assignment(start_date: 7.months.ago)
    create_half_year_mailing(with_half_year_mailing)
    with_no_mailing = make_assignment(start_date: 7.weeks.ago)
    query = Assignment.with_half_year_reminder_mailing
    assert query.include? with_half_year_mailing
    assert_not query.include? with_probation_mailing
    assert_not query.include? with_no_mailing
  end

  test 'with_trial_period_reminder_mailing' do
    with_probation_mailing = make_assignment(start_date: 7.weeks.ago)
    create_probation_mailing(with_probation_mailing)
    with_half_year_mailing = make_assignment(start_date: 7.months.ago)
    create_half_year_mailing(with_half_year_mailing)
    with_no_mailing = make_assignment(start_date: 7.weeks.ago)
    query = Assignment.with_trial_period_reminder_mailing
    assert query.include? with_probation_mailing
    assert_not query.include? with_half_year_mailing
    assert_not query.include? with_no_mailing
  end
end
