require 'test_helper'
require 'utility/group_offer_and_assignment'

class ClientScopesTest < ActiveSupport::TestCase
  include GroupOfferAndAssignment

  def setup
    @now = Time.zone.now
    @with_assignment = create :client
    @with_assignment_between_30_15_days_ago = create :client
    @with_assignment_between_60_30_days_ago = create :client
    @no_assignment = create :client
    [
      { title: 'start_60_days_ago', client: @with_assignment, start_date: @now.days_ago(60) },
      { title: 'end_15_days_ago', client: @with_assignment_between_30_15_days_ago,
        start_date: @now.days_ago(30), end_date: @now.days_ago(15) },
      { title: 'end_30_days_ago', client: @with_assignment_between_60_30_days_ago,
        start_date: @now.days_ago(60), end_date: @now.days_ago(30) }
    ].map { |parameters| make_assignment(parameters) }
  end

  test 'with_assignments returns only clients that have assignments' do
    query = Client.with_assignment
    assert query.include? @with_assignment
    assert query.include? @with_assignment_between_30_15_days_ago
    assert query.include? @with_assignment_between_60_30_days_ago
    refute query.include? @no_assignment
    assert_equal 3, query.count
  end

  test 'with_active_assignments returns only clients that have active assignments' do
    query = Client.with_active_assignment
    assert query.include? @with_assignment
    refute query.include? @with_assignment_between_30_15_days_ago
    refute query.include? @with_assignment_between_60_30_days_ago
    refute query.include? @no_assignment
    assert_equal 1, query.count
  end

  test 'with_active_assignments_between clients that have active assignments in date range' do
    query = Client.with_active_assignment_between(@now.days_ago(80), @now.days_ago(50))
    assert query.include? @with_assignment
    assert query.include? @with_assignment_between_60_30_days_ago
    refute query.include? @with_assignment_between_30_15_days_ago
    refute query.include? @no_assignment
    assert_equal 2, query.count
  end

  test 'without_assignment returns only clients that have no assignments' do
    query = Client.without_assignment
    refute query.include? @with_assignment
    refute query.include? @with_assignment_between_60_30_days_ago
    refute query.include? @with_assignment_between_30_15_days_ago
    assert query.include? @no_assignment
    assert_equal 1, query.count
  end

  test 'with_inactive_assignment returns only clients that have an inactive assignment' do
    query = Client.with_inactive_assignment
    refute query.include? @with_assignment
    assert query.include? @with_assignment_between_60_30_days_ago
    assert query.include? @with_assignment_between_30_15_days_ago
    refute query.include? @no_assignment
    assert_equal 2, query.count
  end
end
