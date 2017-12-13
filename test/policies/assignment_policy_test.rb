require 'test_helper'

class AssignmentPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :department_manager
    @volunteer = create :volunteer_with_user
    @assignment = create :assignment, volunteer: @volunteer
    @other_assignment = create :assignment, volunteer: (create :volunteer_with_user)
  end

  test 'superadmin_can_use_all_actions' do
    assert_permit(@superadmin, Assignment, 'new?', 'create?', 'edit?', 'update?', 'show?', 'index?',
      'destroy?', 'find_client?', 'supervisor?',
      'last_submitted_hours_and_feedbacks?', 'update_submitted_at?')
  end

  test 'department_manager_can_use_all_actions_but_destroy' do
    assert_permit(@department_manager, Assignment, 'new?', 'create?', 'edit?', 'update?', 'show?',
      'index?', 'find_client?', 'supervisor?',
      'last_submitted_hours_and_feedbacks?', 'update_submitted_at?')
    refute_permit(@department_manager, Assignment, 'destroy?')
  end

  test 'social_worker_has_no_access' do
    refute_permit(@social_worker, Assignment, 'new?', 'update?', 'edit?', 'show?', 'index?',
      'destroy?', 'find_client?', 'supervisor?',
      'last_submitted_hours_and_feedbacks?', 'update_submitted_at?')
  end

  test 'volunteer_has_limited_access' do
    assert_permit(@volunteer.user, @assignment, 'edit?', 'update?', 'show?',
      'last_submitted_hours_and_feedbacks?', 'update_submitted_at?')
    refute_permit(@volunteer.user, Assignment, 'new?', 'create?', 'index?',
      'destroy?', 'supervisor?', 'find_client?')
    refute_permit(@volunteer.user, @other_assignment, 'new?', 'create?', 'edit?', 'update?',
      'show?', 'index?', 'destroy?', 'supervisor?', 'find_client?',
      'last_submitted_hours_and_feedbacks?', 'update_submitted_at?')
  end
end
