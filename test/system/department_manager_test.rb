require 'application_system_test_case'

class DepartmentManagerTest < ApplicationSystemTestCase
  def setup
    @department_manager = create :user, :with_profile, role: 'department_manager'
  end

  test 'when updates user login, cannot see role field' do
    login_as @department_manager
    visit edit_user_path(@department_manager)
    assert_not page.has_field? 'role'
  end

  test 'does not have navbar links to users and clients' do
    login_as @department_manager
    visit user_path(@department_manager.id)
    assert_not page.has_link? 'Users'
    assert_not page.has_link? 'Clients'
  end
end
