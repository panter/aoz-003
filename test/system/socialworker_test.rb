require 'application_system_test_case'

class SocialworkerTest < ApplicationSystemTestCase
  def setup
    @socialworker = create :user, :with_profile, :with_clients, role: 'social_worker'
  end

  test 'when logged in socialworker cannot see create superadmin link' do
    login_as @socialworker
    visit root_path

    assert_not page.has_link? 'Create superadmin'
  end

  test 'when updates user login, cannot see role field' do
    login_as @socialworker
    visit edit_user_path(@socialworker)
    assert_not page.has_field? 'role'
  end

  test 'has a navbar link to clients page' do
    login_as @socialworker
    visit user_path(@socialworker.id)
    assert page.has_link? 'Clients'
  end

  test 'can see his clients' do
    login_as @socialworker
    visit clients_path
    @socialworker.clients.each do |client|
      assert page.has_text? client.firstname
      assert page.has_text? client.lastname
      assert page.has_link? href: client_path(client.id)
      assert page.has_link? href: edit_client_path(client.id)
    end
  end

  test 'can only see her own clients' do
    login_as @socialworker
    visit clients_path
    other_socialworker = create :user, :with_profile, :with_clients, role: 'social_worker'
    Client.where(user: other_socialworker) do |client|
      assert_not page.has_text? client.firstname
      assert_not page.has_text? client.lastname
      assert_not page.has_link? href: client_path(client.id)
      assert_not page.has_link? href: edit_client_path(client.id)
    end
  end
end
