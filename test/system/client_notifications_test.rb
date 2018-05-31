require 'application_system_test_case'

class ClientNotificationsTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @social_worker = create :social_worker
    @other_client_notification = create :client_notification, user: @user,
      created_at: 2.hours.ago
    @client_notification = create :client_notification, active: true, user: @user,
      created_at: 1.hour.ago
  end

  test 'the right client notification should be marked active' do
    login_as @user
    visit clients_path
    click_link 'Wartezeitbenachrichtigung'
    assert page.has_text? @client_notification.body
    within 'tr.bg-success' do
      assert page.has_text? @client_notification.body
      assert page.has_selector?('table > tbody td:nth-child(2) i.glyphicon-ok')
      refute page.has_text? @other_client_notification.body
      refute page.has_selector?('table > tbody td:nth-child(2) i.glyphicon-remove')
    end
  end

  test 'changing another notification to active deactivates the former active' do
    login_as @user
    visit client_notifications_path
    within 'tbody tr:last-child' do
      assert page.has_text? @other_client_notification.body
      click_link 'Bearbeiten'
    end
    page.check('client_notification_active')
    click_button 'Klienten Wartezeit Benachrichtigung aktualisieren'
    within 'tr.bg-success' do
      refute page.has_text? @client_notification.body
      assert page.has_text? @other_client_notification.body
    end
  end

  test 'social worker sees notification if a client is registered' do
    login_as @social_worker
    visit clients_path

    click_link 'Klient/in erfassen', match: :first
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'asdf'
    fill_in 'Nachname', with: 'asdf'
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'
    fill_in 'Mailadresse', with: 'gurke@gurkenmail.com'
    fill_in 'Telefonnummer', with: '0123456789', match: :first
    within '#languages' do
      choose('Wenig')
    end
    click_button 'Klient/in erfassen', match: :first
    assert page.has_text? @client_notification.body
  end

  test 'social_worker_always_sees_notification_for_client_registration' do
    @client_notification.update(active: false)
    login_as @social_worker
    visit clients_path

    click_link 'Klient/in erfassen', match: :first
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'asdf'
    fill_in 'Nachname', with: 'asdf'
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'
    fill_in 'Mailadresse', with: 'gurke@gurkenmail.com'
    fill_in 'Telefonnummer', with: '0123456789', match: :first
    within '#languages' do
      choose('Wenig')
    end
    click_button 'Klient/in erfassen', match: :first
    assert page.has_text? 'Klient/in wurde erfolgreich erstellt.'
  end

  test 'social worker does not see notification button on clients index' do
    login_as @social_worker
    visit clients_path

    refute page.has_link? 'Wartezeitbenachrichtigung'
  end

  test 'superadmin does not see this notification' do
    login_as @user
    visit clients_path

    click_link 'Klient/in erfassen', match: :first
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'asdf'
    fill_in 'Nachname', with: 'asdf'
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'
    fill_in 'Mailadresse', with: 'gurke@gurkenmail.com'
    fill_in 'Telefonnummer', with: '0123456789', match: :first
    within '#languages' do
      choose('Wenig')
    end
    click_button 'Klient/in erfassen', match: :first
    assert page.has_text? 'Klient/in wurde erfolgreich erstellt.'
    refute page.has_text? @client_notification.body
  end
end
