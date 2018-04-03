require 'test_helper'

class ClientScopesTest < ActiveSupport::TestCase
  def setup
    @with_active_assignment = create :client
    @with_assignment_between_30_15_days_ago = create :client
    @with_assignment_between_60_30_days_ago = create :client
    @with_active_and_inactive_assignment = create :client
    @no_assignment = create :client

    [
      { title: 'start_60_days_ago', client: @with_active_assignment, start_date: 60.days.ago },
      { title: 'end_15_days_ago', client: @with_assignment_between_30_15_days_ago,
        start_date: 30.days.ago, end_date: 15.days.ago },
      { title: 'end_30_days_ago', client: @with_assignment_between_60_30_days_ago,
        start_date: 60.days.ago, end_date: 30.days.ago },
      { title: 'start_60_days_ago', client: @with_active_and_inactive_assignment,
        start_date: 60.days.ago },
      { title: 'start_60_days_ago', client: @with_active_and_inactive_assignment,
        start_date: 60.days.ago, end_date: 30.days.ago }
    ].each do |parameters|
      make_assignment(parameters)
    end
  end

  test 'with_assignments returns only clients that have assignments' do
    assert_equal [
      @with_active_assignment,
      @with_assignment_between_30_15_days_ago,
      @with_assignment_between_60_30_days_ago,
      @with_active_and_inactive_assignment
    ], Client.with_assignments.order(:id)
  end

  test 'with_active_assignments returns only clients that have active assignments' do
    assert_equal [
      @with_active_assignment,
      @with_active_and_inactive_assignment
    ], Client.with_active_assignments.order(:id)
  end

  test 'without_assignment returns only clients that have no assignments' do
    assert_equal [
      @no_assignment
    ], Client.without_assignments.order(:id)
  end

  test 'with_inactive_assignment returns only clients that have an inactive assignment' do
    assert_equal [
      @with_assignment_between_30_15_days_ago,
      @with_assignment_between_60_30_days_ago,
      @with_active_and_inactive_assignment
    ], Client.with_inactive_assignments.order(:id)
  end

  test 'inactive returns clients without assignments or with only inactive assignments' do
    assert_equal [
      @with_assignment_between_30_15_days_ago,
      @with_assignment_between_60_30_days_ago,
      @no_assignment
    ], Client.inactive.order(:id)
  end
end
