require 'application_system_test_case'

class SocialworkerTest < ApplicationSystemTestCase
  def setup
    @socialworker = create :social_worker, :with_clients
    login_as @socialworker
  end

  test 'when logged in socialworker cannot see create user link' do
    visit root_path
    assert_not page.has_link? 'Benutzer/in erfassen'
  end

  test 'when updates user login, cannot see role field' do
    visit edit_user_path(@socialworker)
    assert_not page.has_field? 'Rolle'
  end

  test 'has a navbar link to clients page' do
    visit user_path(@socialworker.id)
    assert page.has_link? 'Klienten/innen'
  end

  test 'does not have navbar link to users page' do
    visit user_path(@socialworker.id)
    assert_not page.has_link? 'Benutzer/innen'
  end

  test 'can see his clients' do
    visit clients_path
    @socialworker.clients.each do |client|
      assert page.has_text? client.contact.first_name
      assert page.has_text? client.contact.last_name
      assert page.has_link? href: client_path(client.id)
    end
  end

  test 'cannot see comment field in client creation or show' do
    visit new_client_path
    assert_not page.has_field? 'Bemerkungen'
    visit client_path(@socialworker.clients.first)
    assert_not page.has_content? 'Bemerkungen'
  end

  test 'can only see her own clients' do
    visit clients_path
    other_socialworker = create :social_worker, :with_clients
    Client.where(user: other_socialworker) do |client|
      assert_not page.has_text? client.first_name
      assert_not page.has_text? client.last_name
      assert_not page.has_link? href: client_path(client.id)
      assert_not page.has_link? href: edit_client_path(client.id)
    end
  end

  test 'socialworker has no client destroy link' do
    visit clients_path
    assert_not page.has_link? 'Löschen'
  end

  test 'socialworker has no without assignment link' do
    visit clients_path
    assert_not page.has_link? 'Without Assignment'
  end
end
