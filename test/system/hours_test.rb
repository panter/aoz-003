require 'application_system_test_case'

class HoursTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @volunteer1 = create :volunteer_with_user
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

  test 'volunteer can create hour report for an assignment' do
    visit volunteer_path(@volunteer1)
    first(:link, 'Stunden erfassen').click
    assert page.has_text? 'Stunden Rapporte'
    first(:link, 'Stunden erfassen').click
    select @assignment1.to_label, from: 'Einsatz'
    within '#hour_meeting_date_3i' do
      select(Time.zone.today.day)
    end
    within '#hour_meeting_date_2i' do
      select(I18n.l Time.zone.today, format: '%B')
    end
    within '#hour_meeting_date_1i' do
      select(Time.zone.today.year)
    end
    fill_in 'Stunden', with: 2.0
    click_button 'Stunden erfassen'
    assert page.has_text? 'Stunden wurden erfolgreich erfasst.'
  end

  test 'volunteer can create also an hour report for group offer' do
    visit volunteer_path(@volunteer1)
    first(:link, 'Stunden erfassen').click
    assert page.has_text? 'Stunden Rapporte'
    first(:link, 'Stunden erfassen').click
    select @group_offer1.to_label, from: 'Einsatz'
    within '#hour_meeting_date_3i' do
      select(Time.zone.today.day)
    end
    within '#hour_meeting_date_2i' do
      select(I18n.l Time.zone.today, format: '%B')
    end
    within '#hour_meeting_date_1i' do
      select(Time.zone.today.year)
    end
    fill_in 'Stunden', with: 2.0
    click_button 'Stunden erfassen'
    assert page.has_text? 'Stunden wurden erfolgreich erfasst.'
  end

  test 'volunteer can see only her assignment' do
    visit volunteer_path(@volunteer1)
    volunteer2 = create :volunteer_with_user
    client2 = create :client
    client2.contact.first_name = client2.contact.last_name = 'Client2'
    assignment2 = create :assignment, volunteer: volunteer2, client: client2

    create :hour, hourable: @assignment1, volunteer: @volunteer1
    create :hour, hourable: assignment2, volunteer: volunteer2

    first(:link, 'Stunden erfassen').click
    assert page.has_text? @client1.contact.full_name
    refute page.has_text? client2.contact.full_name
    visit volunteer_hours_path(volunteer2)
    assert page.has_text? 'Sie sind nicht berechtigt diese Aktion durchzuführen.'
    refute page.has_text? client2.contact.full_name
  end

  test 'volunteer_can_see_only_her_group_offers' do
    visit volunteer_path(@volunteer1)
    volunteer2 = create :volunteer_with_user
    group_offer2 = create :group_offer, group_offer_category: @group_offer_category,
      title: 'GroupOfferNumberTwo'
    create :group_assignment, group_offer: group_offer2, volunteer: volunteer2,
      period_start: 7.weeks.ago

    create :hour, hourable: @group_offer1, volunteer: @volunteer1
    create :hour, hourable: group_offer2, volunteer: volunteer2
    first(:link, 'Stunden erfassen').click
    assert page.has_text? @group_offer1.to_label
    refute page.has_text? group_offer2.to_label
    visit volunteer_hours_path(volunteer2)
    assert page.has_text? 'Sie sind nicht berechtigt diese Aktion durchzuführen.'
    refute page.has_text? group_offer2.to_label
  end
end
