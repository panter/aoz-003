require 'test_helper'

class VolunteerScopesTest < ActiveSupport::TestCase
  def setup
    @now = Time.zone.now
    @with_assignment = create :volunteer
    @with_multiple_assignments = create :volunteer
    @with_inactive_assignment = create :volunteer
    @no_assignment = create :volunteer
    [
      ['start_60_days_ago', @with_assignment, @now.days_ago(60), nil],
      ['start_in_one_month', @with_multiple_assignments, @now.next_month.end_of_month, nil],
      ['start_7_days_ago', @with_multiple_assignments, @now.days_ago(7), nil],
      ['end_15_days_ago', @with_multiple_assignments, @now.days_ago(30), @now.days_ago(15)],
      ['end_future', @with_multiple_assignments, @now.days_ago(5), @now.next_month.end_of_month],
      ['end_30_days_ago', @with_inactive_assignment, @now.days_ago(60), @now.days_ago(30)]
    ].map { |parameters| make_assignment(*parameters) }
  end

  test 'with_assignments returns only the ones that have assignments' do
    query = Volunteer.with_assignments
    assert query.include? @with_assignment
    assert query.include? @with_multiple_assignments
    assert query.include? @with_inactive_assignment
    refute query.include? @no_assignment
    assert_equal 3, query.count
  end

  test 'with_active_assignments returns only volunteers that have active assignments' do
    query = Volunteer.with_active_assignments
    assert query.include? @with_assignment
    assert query.include? @with_multiple_assignments
    refute query.include? @with_inactive_assignment
    refute query.include? @no_assignment
    assert_equal 2, query.count
  end

  test 'with_active_assignments_between returns volunteers with active assignments in date range' do
    query = Volunteer.with_active_assignments_between(@now.days_ago(16), @now.days_ago(8))
    assert query.include? @with_assignment
    assert query.include? @with_multiple_assignments
    refute query.include? @with_inactive_assignment
    refute query.include? @no_assignment
    assert_equal 2, query.count
  end

  test 'without_assignment returns volunteers with no assignments' do
    query = Volunteer.without_assignment
    refute query.include? @with_assignment
    refute query.include? @with_multiple_assignments
    refute query.include? @with_inactive_assignment
    assert query.include? @no_assignment
    assert_equal 1, query.count
  end

  def make_assignment(title, volunteer, start_date = nil, end_date = nil)
    assignment = create :assignment, volunteer: volunteer, assignment_start: start_date,
      assignment_end: end_date
    instance_variable_set("@#{title}", assignment)
  end
end
