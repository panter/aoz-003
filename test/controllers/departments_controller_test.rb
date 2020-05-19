require 'test_helper'

class DepartmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Department.destroy_all
    @superadmin = create :user, :with_clients,
      :with_department, role: 'superadmin'
    @social_worker = create :user, :with_clients,
      :with_department, role: 'social_worker'
    @department_manager = create :department_manager
  end

  test 'superadmin can update user_ids' do
    login_as @superadmin
    department = @superadmin.department.first
    params = {
      department: {
        user_ids: [
          @superadmin.id,
          @department_manager.id,
          ''
        ],
        contact_attributes: { last_name: 'Another name' }
      },
      commit: 'Update Department'
    }
    put department_path(department.id), params: params
    department_updated = Department.find department.id
    assert department_updated.contact.last_name == 'Another name'
    assert department_updated.user_ids.include? @department_manager.id
  end

  test 'department_manager can not submit user associations' do
    login_as @department_manager
    department = @department_manager.department.first
    params = {
      department: {
        user_ids: [
          @superadmin.id,
          @department_manager.id,
          ''
        ],
        contact_attributes: { last_name: 'new name' }
      },
      commit: 'Update Department'
    }
    put department_path(department.id), params: params
    department_updated = Department.find department.id
    assert department_updated.contact.last_name == 'new name'
    refute department_updated.user_ids.include? @superadmin.id
  end
end
