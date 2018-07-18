require 'application_system_test_case'

class HoursTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @volunteer1 = create :volunteer
    @user_volunteer1 = @volunteer1.user
    @client1 = create :client
    @client1.contact.first_name = @client1.contact.last_name = 'Client1'
    @assignment1 = create :assignment, volunteer: @volunteer1, client: @client1,
      period_start: 7.weeks.ago
    @group_offer_category = create :group_offer_category
    @group_offer1 = create :group_offer, title: 'GroupOfferNumberOne',
      group_offer_category: @group_offer_category
    create :group_assignment, group_offer: @group_offer1, volunteer: @volunteer1,
      period_start: 7.weeks.ago
    login_as @user_volunteer1
  end

  test 'volunteer_can_create_hour_report_for_an_assignment' do
    visit volunteer_path(@volunteer1)
    first(:link, 'Stunden erfassen').click
    assert_text 'Stunden Rapporte'
    first(:link, 'Stunden erfassen').click
    select @assignment1.to_label, from: 'Einsatz'
    fill_in 'Datum des Treffens / des Kurses', with: 2.weeks.ago.strftime('%d.%m.%Y')
    find('#hour_meeting_date').send_keys(:return)
    fill_in 'Stunden', with: 2.0
    click_button 'Stunden erfassen'
    assert_text 'Stunden wurden erfolgreich erfasst.'
  end

  test 'volunteer_can_create_also_an_hour_report_for_group_offer' do
    visit volunteer_path(@volunteer1)
    first(:link, 'Stunden erfassen').click
    assert_text 'Stunden Rapporte'
    first(:link, 'Stunden erfassen').click
    select @group_offer1.to_label, from: 'Einsatz'
    fill_in 'Datum des Treffens / des Kurses', with: 3.weeks.ago.strftime('%d.%m.%Y')
    find('#hour_meeting_date').send_keys(:return)
    fill_in 'Stunden', with: 2.0
    click_button 'Stunden erfassen'
    assert_text 'Stunden wurden erfolgreich erfasst.'
  end

  test 'volunteer_can_see_only_her_assignment' do
    visit volunteer_path(@volunteer1)
    volunteer2 = create :volunteer
    client2 = create :client
    client2.contact.first_name = client2.contact.last_name = 'Client2'
    assignment2 = create :assignment, volunteer: volunteer2, client: client2

    create :hour, hourable: @assignment1, volunteer: @volunteer1
    create :hour, hourable: assignment2, volunteer: volunteer2

    first(:link, 'Stunden erfassen').click
    assert_text @client1.contact.full_name
    assert_no_text client2.contact.full_name
    visit volunteer_hours_path(volunteer2)
    assert_text 'Sie sind nicht berechtigt diese Aktion durchzuführen.'
    assert_no_text client2.contact.full_name
  end

  test 'volunteer_can_see_only_her_group_offers' do
    visit volunteer_path(@volunteer1)
    volunteer2 = create :volunteer
    group_offer2 = create :group_offer, group_offer_category: @group_offer_category,
      title: 'GroupOfferNumberTwo'
    create :group_assignment, group_offer: group_offer2, volunteer: volunteer2,
      period_start: 7.weeks.ago

    create :hour, hourable: @group_offer1, volunteer: @volunteer1
    create :hour, hourable: group_offer2, volunteer: volunteer2
    first(:link, 'Stunden erfassen').click
    assert_text @group_offer1.to_label
    assert_no_text group_offer2.to_label
    visit volunteer_hours_path(volunteer2)
    assert_text 'Sie sind nicht berechtigt diese Aktion durchzuführen.'
    assert_no_text group_offer2.to_label
  end
end
