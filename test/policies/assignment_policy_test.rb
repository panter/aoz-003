require 'test_helper'

class AssignmentPolicyTest < PolicyAssertions::Test
  def setup
    @actions = ['index?', 'terminated_index?', 'search?', 'new?', 'create?', 'find_client?',
                'show?', 'edit?', 'update?', 'update_submitted_at?', 'terminate?',
                'update_terminated_at?', 'last_submitted_hours_and_feedbacks?',
                'verify_termination?', 'destroy?']
  end

  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), Assignment, *@actions)
  end

  test 'department_manager_has_limited_access' do
    department_manager = create(:department_manager)
    assignment_department_manager = create :assignment, creator: department_manager
    assert_permit(department_manager, Assignment, *@actions[0..5])
    assert_permit(department_manager, assignment_department_manager, *@actions[6..-3])
    refute_permit(department_manager, create(:assignment), *@actions[6..-3])
    refute_permit(department_manager, Assignment, *@actions[-2..-1])
  end

  test 'social_worker_has_no_access' do
    refute_permit(create(:social_worker), Assignment, *@actions)
  end

  test 'volunteer_has_limited_access' do
    volunteer = create :volunteer_with_user
    assignment = create :assignment, volunteer: volunteer
    other_assignment = create :assignment, volunteer: (create :volunteer_with_user)
    assert_permit(volunteer.user, assignment, *@actions[6..12])
    refute_permit(volunteer.user, Assignment, *@actions[0..5], *@actions[-2..-1])
    refute_permit(volunteer.user, other_assignment, *@actions)
  end
end
