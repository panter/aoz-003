require 'application_system_test_case'

class HoursTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @volunteer1 = create :volunteer_with_user
    @volunteer1.user.update(email: 'volunteer1@example.com')
    @volunteer1.contact.update(primary_email: 'volunteer1@example.com')
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
    visit root_url
    click_link @user_volunteer1.navigation_name
    click_link 'Profil anzeigen'
  end

  test 'volunteer can create hour report for an assignment' do
    click_link 'Report hours'
    select @assignment1.to_label, from: 'Assignment'
    within '#hour_meeting_date_3i' do
      select(Time.zone.today.day)
    end
    within '#hour_meeting_date_2i' do
      select(Time.zone.today.strftime('%B'))
    end
    within '#hour_meeting_date_1i' do
      select(Time.zone.today.year)
    end
    select '2', from: 'Hours'
    select '15', from: 'Minutes'
    click_button 'Create Hour report'
    assert page.has_text? 'Hour report was successfully created.'
  end

  test 'volunteer can create also an hour report for group offer' do
    click_link 'Report hours'
    select @group_offer1.to_label, from: 'Assignment'
    within '#hour_meeting_date_3i' do
      select(Time.zone.today.day)
    end
    within '#hour_meeting_date_2i' do
      select(Time.zone.today.strftime('%B'))
    end
    within '#hour_meeting_date_1i' do
      select(Time.zone.today.year)
    end
    select '2', from: 'Hours'
    select '15', from: 'Minutes'
    click_button 'Create Hour report'
    assert page.has_text? 'Hour report was successfully created.'
  end

  test 'volunteer can see only her assignment' do
    user_volunteer2 = create :user, role: 'volunteer', email: 'volunteer2@example.com'
    volunteer2 = user_volunteer2.volunteer = create :volunteer
    client2 = create :client
    client2.contact.first_name = client2.contact.last_name = 'Client2'
    assignment2 = create :assignment, volunteer: volunteer2, client: client2

    create :hour, hourable: @assignment1, volunteer: @volunteer1
    create :hour, hourable: assignment2, volunteer: volunteer2

    click_link 'Hour reports'
    assert page.has_text? @client1.contact.full_name
    refute page.has_text? client2.contact.full_name
    visit volunteer_hours_path(volunteer2)
    assert page.has_text? 'You are not authorized to perform this action.'
    refute page.has_text? client2.contact.full_name
  end

  test 'volunteer_can_see_only_her_group_offers' do
    volunteer2 = create :volunteer_with_user
    volunteer2.user.update(email: 'volunteer2@example.com')
    volunteer2.contact.update(primary_email: 'volunteer2@example.com')
    group_offer2 = create :group_offer, group_offer_category: @group_offer_category,
      title: 'GroupOfferNumberTwo'
    create :group_assignment, group_offer: group_offer2, volunteer: volunteer2,
      period_start: 7.weeks.ago

    create :hour, hourable: @group_offer1, volunteer: @volunteer1
    create :hour, hourable: group_offer2, volunteer: volunteer2
    click_link 'Hour reports'
    assert page.has_text? @group_offer1.to_label
    refute page.has_text? group_offer2.to_label
    visit volunteer_hours_path(volunteer2)
    assert page.has_text? 'You are not authorized to perform this action.'
    refute page.has_text? group_offer2.to_label
  end
end
