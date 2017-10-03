require 'application_system_test_case'

class DepartmentManagerTest < ApplicationSystemTestCase
  def setup
    @department_manager = create :user, role: 'department_manager'
    3.times do
      create :client, user: @department_manager
    end
    login_as @department_manager
  end

  test 'when updates user login, cannot see role field' do
    visit edit_user_path(@department_manager)
    assert_not page.has_field? 'Role'
  end

  test 'does not have navbar links to users' do
    visit user_path(@department_manager.id)
    assert_not page.has_link? 'Users'
  end

  test 'has a navbar link to clients page' do
    visit user_path(@department_manager.id)
    assert page.has_link? 'Clients'
  end

  test 'can see his clients' do
    visit clients_path
    @department_manager.clients.each do |client|
      assert page.has_text? client.contact.first_name
      assert page.has_text? client.contact.last_name
      assert page.has_link? href: client_path(client.id)
      assert page.has_link? href: edit_client_path(client.id)
    end
  end
end
