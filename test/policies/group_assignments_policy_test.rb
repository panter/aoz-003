require 'test_helper'

class GroupAssignmentPolicyTest < PolicyAssertions::Test
  def setup
    @volunteer = create :volunteer_with_user
    @superadmin = create :user
    @other_volunteer = create :volunteer_with_user
    @department_manager = create :department_manager
    @social_worker = create :social_worker
    @group_offer = create :group_offer, creator: @department_manager,
      department: @department_manager.department.first
    @group_assignment = create :group_assignment, volunteer: @volunteer, group_offer: @group_offer
    @group_assignment_other_volunteer = create :group_assignment, group_offer: @group_offer,
      volunteer: @other_volunteer
    @group_assignment_other_group_offer = create :group_assignment
  end

  test 'superadmin_can_use_all_actions' do
    assert_permit(@superadmin, GroupAssignment, 'verify_termination?', 'set_end_today?', 'edit?',
      'update?', 'show?', 'update_submitted_at?', 'terminate?', 'update_terminated_at?',
      'last_submitted_hours_and_feedbacks?')
  end

  test 'department_manager_can_use_all_actions' do
    assert_permit(@department_manager, GroupAssignment, 'verify_termination?', 'set_end_today?',
      'edit?', 'update?', 'show?', 'update_submitted_at?', 'terminate?', 'update_terminated_at?',
      'last_submitted_hours_and_feedbacks?')
  end

  test 'social_worker_has_no_access' do
    refute_permit(@social_worker, GroupAssignment, 'verify_termination?', 'set_end_today?',
      'edit?', 'update?', 'show?', 'update_submitted_at?', 'terminate?', 'update_terminated_at?',
      'last_submitted_hours_and_feedbacks?')
  end

  test 'volunteer_has_limited_access' do
    assert_permit(@volunteer.user, @group_assignment, 'update?', 'show?', 'update_submitted_at?',
      'terminate?', 'update_terminated_at?', 'last_submitted_hours_and_feedbacks?')
    refute_permit(@volunteer.user, @group_assignment, 'verify_termination?', 'set_end_today?',
      'edit?')
    refute_permit(@volunteer.user, @group_assignment_other_volunteer, 'update?', 'show?',
      'update_submitted_at?', 'terminate?', 'update_terminated_at?', 'set_end_today?',
      'last_submitted_hours_and_feedbacks?', 'verify_termination?', 'edit?')
  end
end
