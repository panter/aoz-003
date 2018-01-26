require 'test_helper'

class GroupAssignmentPolicyTest < PolicyAssertions::Test
  def setup
    @actions = ['verify_termination?', 'terminated_index?', 'edit?', 'set_end_today?', 'update?',
                'terminate?', 'update_submitted_at?', 'show?', 'update_terminated_at?',
                'last_submitted_hours_and_feedbacks?']
  end

  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), GroupAssignment, *@actions)
  end

  test 'department_manager_has_limited_access' do
    department_manager = create :department_manager
    department_manager_group_assignment = create :group_assignment,
      group_offer: create(:group_offer, creator: department_manager)
    refute_permit(department_manager, GroupAssignment, *@actions[0])
    assert_permit(department_manager, GroupAssignment, *@actions[1])
    assert_permit(department_manager, department_manager_group_assignment, *@actions[2..-1])
    refute_permit(department_manager, create(:group_assignment), *@actions[2..-1])
  end

  test 'social_worker_has_no_access' do
    refute_permit(create(:social_worker), GroupAssignment, *@actions)
  end

  test 'volunteer_has_limited_access' do
    volunteer = create :volunteer_with_user
    volunteer_group_assignment =  create :group_assignment, volunteer: volunteer
    refute_permit(volunteer.user, GroupAssignment, *@actions[0..4])
    assert_permit(volunteer.user, volunteer_group_assignment, *@actions[5..-1])
    refute_permit(volunteer.user, create(:group_assignment), *@actions[5..-1])
  end
end
