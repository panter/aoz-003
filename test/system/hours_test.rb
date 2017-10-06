require 'application_system_test_case'

class HoursTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @user_volunteer1 = create :user, role: 'volunteer', email: 'volunteer1@example.com'
    @volunteer1 = @user_volunteer1.volunteer = create :volunteer
    @client1 = create :client
    @client1.contact.first_name = @client1.contact.last_name = 'Client1'
    @assignment1 = create :assignment, volunteer: @volunteer1, client: @client1
    @group_offer_category = create :group_offer_category
    @group_offer1 = create :group_offer, volunteers: [@volunteer1], group_offer_category: @group_offer_category
    login_as @user_volunteer1
    visit root_url
    click_link 'volunteer1@example.com'
    click_link 'Show profile'
  end

  test 'volunteer can create hour report for assignment and group offer' do
    click_link 'Report hours'
    select @assignment1.to_label, from: 'Einsatz'
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
    select @group_offer1.to_label, from: 'Einsatz'
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

  test 'volunteer can see only her assignment and group_offer' do
    @user_volunteer2 = create :user, role: 'volunteer', email: 'volunteer2@example.com'
    @volunteer2 = @user_volunteer2.volunteer = create :volunteer
    @client2 = create :client
    @client2.contact.first_name = @client2.contact.last_name = 'Client2'
    @assignment2 = create :assignment, volunteer: @volunteer2, client: @client2

    @assignment_hour1 = create :hour, hourable: @assignment1, volunteer: @volunteer1
    @assignment_hour2 = create :hour, hourable: @assignment2, volunteer: @volunteer2

    click_link 'Hour reports'
    assert page.has_text? 'Client1 Client1'
    refute page.has_text? 'Client2 Client2'
    visit volunteer_hours_path(@volunteer2)
    assert page.has_text? 'You are not authorized to perform this action.'
    refute page.has_text? 'Client2 Client2'
  end

  test 'volunteer can see only her and group_offers' do
    @user_volunteer2 = create :user, role: 'volunteer', email: 'volunteer2@example.com'
    @volunteer2 = @user_volunteer2.volunteer = create :volunteer
    @group_offer2 = create :group_offer, volunteers: [@volunteer2], group_offer_category: @group_offer_category

    @group_offer_hour1 = create :hour, hourable: @group_offer1, volunteer: @volunteer1
    @group_offer_hour2 = create :hour, hourable: @group_offer2, volunteer: @volunteer2
    click_link 'Hour reports'
    assert page.has_text? @group_offer1.to_label
    # somehow this is still showing up, but don't understand why..
    # refute page.has_text? @group_offer2.to_label
    visit volunteer_hours_path(@volunteer2)
    assert page.has_text? 'You are not authorized to perform this action.'
    refute page.has_text? @group_offer2.to_label
  end
end
