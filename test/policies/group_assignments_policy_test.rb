require 'test_helper'

class GroupAssignmentPolicyTest < PolicyAssertions::Test
  def setup
    @volunteer = create :volunteer_with_user
    @superadmin = create :user
    @other_volunteer = create :volunteer_with_user
    @department_manager = create :department_manager
    @social_worker = create :social_worker
    @group_assignment = GroupAssignment.create(volunteer: @volunteer,
      group_offer: (create :group_offer))
    @other_group_assignment = GroupAssignment.create(volunteer: @other_volunteer,
      group_offer: (create :group_offer))
  end

  test 'superadmin_can_use_all_actions' do
    assert_permit(@superadmin, GroupAssignment, 'update?', 'show?',
      'last_submitted_hours_and_feedbacks?')
  end

  test 'department_manager_can_use_all_actions' do
    assert_permit(@department_manager, GroupAssignment, 'update?', 'show?',
      'last_submitted_hours_and_feedbacks?')
  end

  test 'social_worker_has_no_access' do
    refute_permit(@social_worker, GroupAssignment, 'update?', 'show?',
      'last_submitted_hours_and_feedbacks?')
  end

  test 'volunteer_has_limited_access' do
    assert_permit(@volunteer.user, @group_assignment, 'update?', 'show?',
      'last_submitted_hours_and_feedbacks?')
    refute_permit(@volunteer.user, @other_group_assignment, 'update?', 'show?',
      'last_submitted_hours_and_feedbacks?')
  end
end
