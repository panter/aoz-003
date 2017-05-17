require 'test_helper'

class DepartmentPolicyTest < ActiveSupport::TestCase
  def setup
    @superadmin = create :user, :with_clients, :with_profile, :with_departments, role: 'superadmin'
    @social_worker = create :user, :with_clients, :with_profile, role: 'social_worker'
    @department_manager = create :user, :with_profile, :with_departments, role: 'department_manager'
    @department = create :department
  end

  test 'only superadmin can create department' do
    department_params = {
      contact: Contact.new(name: 'department'),
      user: [@social_worker]
    }
    assert_permit @superadmin, Department.new(department_params), 'create?', 'new?'
  end

  test 'only superadmin can access departments' do
    assert_permit @superadmin, @department, 'index?', 'show?', 'edit?', 'update?', 'destroy?'
    refute_permit @social_worker, @department, 'index?', 'show?', 'edit?', 'update?', 'destroy?'
    refute_permit @department_manager, @department, 'index?', 'edit?', 'update?', 'destroy?'
  end
end
