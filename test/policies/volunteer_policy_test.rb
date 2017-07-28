require 'test_helper'

class VolunteerPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :user, role: 'department_manager'
  end

  test 'Create: only superadmin can create volunteer' do
    assert_permit @superadmin, Volunteer, 'new?', 'create?'
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

  test 'Seeking clients: superadmin can see volunteers seeking clients' do
    assert_permit @superadmin, Volunteer, 'seeking_clients?'
  end

  test 'Seeking clients: social worker cannot see volunteers seeking clients' do
    refute_permit @social_worker, Volunteer, 'seeking_clients?'
  end

  test 'Seeking clients: department manager cannot see volunteers seeking clients' do
    refute_permit @department_manager, Volunteer, 'seeking_clients?'
  end

  test "Checklist: superadmin can see volunteer's checklist" do
    assert_permit @superadmin, Volunteer, 'checklist?'
  end

  test "Checklist: social worker can see volunteer's checklist" do
    refute_permit @social_worker, Volunteer, 'checklist?'
  end

  test "Checklist: department manager cannot see volunteer's checklist" do
    refute_permit @department_manager, Volunteer, 'checklist?'
  end
end
