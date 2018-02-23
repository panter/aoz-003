require 'test_helper'

class GroupAssignmentArchiveTest < ActiveSupport::TestCase
  test 'change_period_start_does_not_create_a_log' do
    group_assignment = create :group_assignment, period_start: 100.days.ago, period_end: nil
    assert group_assignment.group_assignment_logs.size.zero?
    group_assignment.update(period_start: 50.days.ago)
    group_assignment.reload
    assert group_assignment.present?
    refute group_assignment.group_assignment_logs.any?
  end

  test 'set_period_end_does_not_create_a_log' do
    group_assignment = create :group_assignment, period_start: 100.days.ago, period_end: nil
    assert group_assignment.group_assignment_logs.size.zero?
    group_assignment.update(period_end: 2.days.ago)
    group_assignment.reload
    assert group_assignment.ended?
    refute group_assignment.group_assignment_logs.any?
  end

  test 'terminating_group_assignment_creates_log_but_not_deletes_self' do
    superadmin = create :user
    group_assignment = create :group_assignment, period_start: 100.days.ago,
      period_end: 3.days.ago,
      period_end_set_by: superadmin, termination_submitted_at: 2.days.ago,
      termination_submitted_by: superadmin
    assert group_assignment.group_assignment_logs.size.zero?
    group_assignment.verify_termination(superadmin)
    group_assignment.reload
    assert_equal group_assignment, group_assignment.group_assignment_logs.first.group_assignment
    assert group_assignment.group_assignment_logs.first.group_assignment
    refute group_assignment.deleted?
  end

  test 'destroying_group_assignment_does_not_create_log_if_not_verified' do
    group_assignment = create :group_assignment, period_start: 100.days.ago, period_end: nil
    assert group_assignment.group_assignment_logs.size.zero?
    group_assignment.destroy
    group_assignment.reload
    refute group_assignment.group_assignment_logs.any?
    assert group_assignment.deleted?
  end

  test 'change_responsible_does_not_create_log' do
    group_assignment = create :group_assignment, period_start: 100.days.ago, period_end: nil,
      responsible: false
    assert group_assignment.group_assignment_logs.size.zero?
    group_assignment.update(responsible: true)
    group_assignment.reload
    assert group_assignment.group_assignment_logs.size.zero?
  end
end
