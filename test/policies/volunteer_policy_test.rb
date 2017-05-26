require 'test_helper'

class VolunteerPolicyTest < ActiveSupport::TestCase
  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :user, role: 'department_manager'
  end

  test 'No user can create volunteer' do
    refute_permit @superadmin, Volunteer, 'new?', 'create?'
    refute_permit @social_worker, Volunteer, 'new?', 'create?'
    refute_permit @department_manager, Volunteer, 'new?', 'create?'
  end

  test 'Destroy: only superadmin can destroy' do
    assert_permit @superadmin, Volunteer, 'destroy?'
    refute_permit @social_worker, Volunteer, 'destroy?'
    refute_permit @department_manager, Volunteer, 'destroy?'
  end

  test 'Update: only superadmin can update and show all volunteers' do
    assert_permit @superadmin, Volunteer, 'update?', 'edit?', 'show?'
    refute_permit @social_worker, Volunteer, 'update?', 'edit?', 'show?'
    refute_permit @department_manager, Volunteer, 'update?', 'edit?', 'show?'
  end

  test 'Index: only a superadmin can index Volunteers' do
    assert_permit @superadmin, Volunteer, 'index?'
    refute_permit @department_manager, Volunteer, 'index?'
    refute_permit @social_worker, Volunteer, 'index?'
  end
end
