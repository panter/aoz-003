require 'test_helper'
class DepartmentPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, :with_clients, :with_profile, :with_departments, role: 'superadmin'
    @social_worker = create :user, :with_clients, :with_profile, role: 'social_worker'
    @department_manager = create :user, :with_profile, :with_departments, role: 'department_manager'
    @department = create :department
  end

  test 'only superadmin can create department' do
    department_params = {
      contact: Contact.new(last_name: 'department'),
      user: [@social_worker]
    }
    assert_permit @superadmin, Department.new(department_params), 'create?', 'new?'
  end

  test 'department access rights for superadmin, socialworker and department_manager' do
    assert_permit(
      @superadmin, @department,
      'index?', 'show?', 'new?', 'edit?', 'create?', 'update?', 'destroy?'
    )
    refute_permit(
      @social_worker, @department,
      'index?', 'show?', 'new?', 'edit?', 'create?', 'update?', 'destroy?'
    )
  end

  test 'departmentmanager can edit and show the associeted department' do
    refute_permit(
      @department_manager, @department,
      'index?', 'show?', 'new?', 'edit?', 'create?', 'update?', 'destroy?'
    )
    assert_permit(
      @department_manager, @department_manager.department.first,
      'show?', 'edit?', 'update?'
    )
  end
end
