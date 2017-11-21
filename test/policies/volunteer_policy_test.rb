require 'test_helper'

class VolunteerPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user
    @social_worker = create :social_worker
    @department_manager = create :department_manager
    @volunteer_seeks = create :volunteer_with_user,
      assignments: [create(:assignment, period_start: 500.days.ago, period_end: 200.days.ago)]
    @volunteer_not_seeking = create :volunteer_with_user,
      assignments: [create(:assignment, period_start: 10.days.ago, period_end: nil)]
  end

  test 'Create: only superadmin can create volunteer' do
    assert_permit @superadmin, Volunteer, 'new?', 'create?'
    assert_permit @social_worker, Volunteer, 'new?', 'create?'
    assert_permit @department_manager, Volunteer, 'new?', 'create?'
    refute_permit @volunteer_seeks.user, Volunteer, 'new?', 'create?'
  end

  test 'Destroy: only superadmin can destroy' do
    assert_permit @superadmin, Volunteer, 'destroy?'
    refute_permit @social_worker, Volunteer, 'destroy?'
    refute_permit @department_manager, Volunteer, 'destroy?'
    refute_permit @volunteer_seeks.user, Volunteer, 'destroy?'
  end

  test 'Update: only superadmin can update and show all volunteers' do
    assert_permit @superadmin, Volunteer, 'update?', 'edit?', 'show?'
    assert_permit @social_worker, Volunteer, 'update?', 'edit?', 'show?'
    assert_permit @department_manager, Volunteer, 'update?', 'edit?', 'show?'
    assert_permit @volunteer_seeks.user, @volunteer_seeks, 'update?', 'edit?', 'show?'
    refute_permit @volunteer_not_seeking.user, @volunteer_seeks, 'update?', 'edit?', 'show?'
  end

  test 'Index: only Superadmins, Department managers and Social workers can index Volunteers' do
    assert_permit @superadmin, Volunteer, 'index?', 'seeking_clients?'
    assert_permit @department_manager, Volunteer, 'index?', 'seeking_clients?'
    assert_permit @social_worker, Volunteer, 'index?', 'seeking_clients?'
    refute_permit @volunteer_seeks.user, Volunteer, 'index?', 'seeking_clients?'
  end
end
