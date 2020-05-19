require 'application_system_test_case'

class SocialworkerTest < ApplicationSystemTestCase
  def setup
    @socialworker = create :social_worker, :with_clients
    login_as @socialworker
  end

  test 'when logged in socialworker cannot see create user link' do
    visit root_path
    assert_css 'h1', text: 'Klient/innen'
    refute_link 'Benutzer/in erfassen', wait: 0
  end

  test 'when updates user login, cannot see role field' do
    visit edit_user_path(@socialworker)
    assert_text 'Login bearbeiten'
    refute_field 'Rolle', wait: 0
  end

  test 'has a navbar link to clients page' do
    visit user_path(@socialworker.id)
    assert_text "Profil von #{@socialworker.full_name}"
    assert_link 'Klient/innen'
  end

  test 'does not have navbar link to users page' do
    visit user_path(@socialworker.id)
    assert_text "Profil von #{@socialworker.full_name}"
    refute_link 'Benutzer/innen', wait: 0
  end

  test 'can see his clients' do
    visit clients_path
    @socialworker.clients.each do |client|
      assert_text client.contact.first_name
      assert_text client.contact.last_name
      assert_link href: client_path(client.id)
    end
  end

  test 'can only see her own clients' do
    other_socialworker = create :social_worker, :with_clients
    visit clients_path
    assert_css 'h1', text: 'Klient/innen'
    Client.where(user: other_socialworker) do |client|
      refute_text client.first_name, wait: 0
      refute_text client.last_name, wait: 0
      refute_link href: client_path(client.id), wait: 0
      refute_link href: edit_client_path(client.id), wait: 0
    end
  end

  test 'socialworker has no without assignment link' do
    visit clients_path
    assert_css 'h1', text: 'Klient/innen'
    refute_link 'Without Assignment', wait: 0
  end
end
