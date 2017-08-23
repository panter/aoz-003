require 'test_helper'

class AssignmentScopesTest < ActiveSupport::TestCase
  def setup
    @now = Time.zone.now
    [
      ['start_60_days_ago', @now.days_ago(60), nil],
      ['start_in_one_month', @now.next_month.end_of_month, nil],
      ['start_7_days_ago', @now.days_ago(7), nil],
      ['end_30_days_ago', @now.days_ago(60), @now.days_ago(30)],
      ['end_15_days_ago', @now.days_ago(30), @now.days_ago(15)],
      ['end_future', @now.days_ago(5), @now.next_month.end_of_month]
    ].map { |parameters| make_assignment(*parameters) }
  end

  test 'no_end returns only with no end date set' do
    query = Assignment.no_end
    assert query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    refute query.include? @end_future
  end

  test 'has_end returns only with end date set' do
    query = Assignment.has_end
    refute query.include? @start_60_days_ago
    assert query.include? @end_30_days_ago
    assert query.include? @end_future
  end

  test 'end_in_past returns only with end_date in past' do
    query = Assignment.ended
    refute query.include? @start_60_days_ago
    assert query.include? @end_30_days_ago
    refute query.include? @end_future
  end

  test 'end_before returns only ended before parameter' do
    query = Assignment.end_before(@now.days_ago(20))
    refute query.include? @start_60_days_ago
    assert query.include? @end_30_days_ago
    refute query.include? @end_15_days_ago
    refute query.include? @end_future
  end

  test 'end_after returns only ended after parameter' do
    query = Assignment.end_after(@now.days_ago(20))
    refute query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    assert query.include? @end_15_days_ago
    assert query.include? @end_future
  end

  test 'end_within returns only ended between range' do
    query = Assignment.end_within(@now.days_ago(20)..@now.days_ago(10))
    refute query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    assert query.include? @end_15_days_ago
    refute query.include? @end_future
  end

  test 'end_in_future returns only ending in the future' do
    query = Assignment.end_in_future
    refute query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    refute query.include? @end_15_days_ago
    assert query.include? @end_future
  end

  test 'not_ended returns only with no ending or ending in future' do
    query = Assignment.not_ended
    assert query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    refute query.include? @end_15_days_ago
    assert query.include? @end_future
  end

  test 'started returns only with start date in past' do
    query = Assignment.started
    assert query.include? @start_60_days_ago
    assert query.include? @end_30_days_ago
    assert query.include? @end_15_days_ago
    assert query.include? @end_future
    refute query.include? @start_in_one_month
  end

  test 'start_before returns only with start date before given date' do
    query = Assignment.start_before(@now.days_ago(31))
    assert query.include? @start_60_days_ago
    assert query.include? @end_30_days_ago
    refute query.include? @end_15_days_ago
    refute query.include? @end_future
    refute query.include? @start_in_one_month
  end

  test 'start_after returns only with start date after given date' do
    query = Assignment.start_after(@now.days_ago(29))
    refute query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    refute query.include? @end_15_days_ago
    assert query.include? @end_future
    assert query.include? @start_in_one_month
  end

  test 'start_within returns only with start date after given date' do
    query = Assignment.start_within(@now.days_ago(32)..@now.days_ago(12))
    refute query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    assert query.include? @end_15_days_ago
    refute query.include? @end_future
    refute query.include? @start_in_one_month
  end

  test 'active returns only started and not ended' do
    query = Assignment.active
    assert query.include? @start_60_days_ago
    refute query.include? @end_30_days_ago
    refute query.include? @end_15_days_ago
    assert query.include? @end_future
    refute query.include? @start_in_one_month
  end

  test 'active_between returns only started and not ended between start and end date' do
    query = Assignment.active_between(@now.days_ago(40), @now.days_ago(20))
    assert query.include? @start_60_days_ago
    assert query.include? @end_30_days_ago
    assert query.include? @end_15_days_ago
    refute query.include? @end_future
    refute query.include? @start_in_one_month
    refute query.include? @start_7_days_ago
  end

  def make_assignment(title, start_date = nil, end_date = nil)
    assignment = create :assignment, assignment_start: start_date, assignment_end: end_date
    instance_variable_set("@#{title}", assignment)
  end
end
