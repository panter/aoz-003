require 'application_system_test_case'

class AssignmentSearchesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user

    # VOLUNTEERS
    @volunteer1 = create :volunteer
    @volunteer1.contact.update(first_name: 'Walter', last_name: 'White')

    @volunteer2 = create :volunteer
    @volunteer2.contact.update(first_name: 'Jesse', last_name: 'Pinkman')

    @volunteer3 = create :volunteer
    @volunteer3.contact.update(first_name: 'Skyler', last_name: 'White')

    # CLIENTS
    @client1 = create :client, user: @superadmin
    @client1.contact.update(first_name: 'Amy', last_name: 'Pond')

    @client2 = create :client, user: @superadmin
    @client2.contact.update(first_name: 'Rory', last_name: 'Williams')

    @client3 = create :client, user: @superadmin
    @client3.contact.update(first_name: 'River', last_name: 'Song')


    # ASSIGNMENTS
    @assignment1 = create :assignment, volunteer: @volunteer1, client: @client1
    @assignment2 = create :assignment, volunteer: @volunteer2, client: @client2
    @assignment3 = create :assignment, volunteer: @volunteer3, client: @client3

    login_as @superadmin
    visit assignments_path
  end

  # VOLUNTEER SEARCH
  test 'basic_non_suggests_volunteer_search_works' do
    fill_in name: 'q[volunteer_contact_full_name_cont]', with: 'Whi'
    wait_for_ajax
    page.find_field(name: 'q[volunteer_contact_full_name_cont]').native.send_keys(:tab, :enter)
    visit current_url
    assert_text @assignment1.volunteer.contact.full_name
    assert_text @assignment3.volunteer.contact.full_name
    refute_text @assignment2.volunteer.contact.full_name
  end

  test 'enter_volunteer_search_text_brings_suggestions' do
    fill_autocomplete 'q[volunteer_contact_full_name_cont]', with: 'Whi', items_expected: 2,
      check_items: [@assignment1.volunteer.contact.full_name, @assignment3.volunteer.contact.full_name]
  end

  test 'suggestions volunteer search triggers the search correctly' do
    fill_autocomplete 'q[volunteer_contact_full_name_cont]', with: 'Wal'
    click_button 'Freiwillige Suchen'
    visit current_url
    within 'tbody' do
      assert_text @assignment1.volunteer.contact.full_name
      assert_equal 1, find_all('tr').size
    end
  end

  test 'searching for a volunteer, does not mix up with clients name' do
    fill_autocomplete 'q[volunteer_contact_full_name_cont]', with: 'er', items_expected: 2,
      check_items: [@assignment1.volunteer.contact.full_name, @assignment3.volunteer.contact.full_name]
  end

  # ClIENT SEARCH
  test 'basic_non_suggests_client_search_works' do
    fill_in name: 'q[client_contact_full_name_cont]', with: 'R'
    wait_for_ajax
    page.find_field(name: 'q[client_contact_full_name_cont]').native.send_keys(:tab, :enter)
    visit current_url
    assert_text @assignment2.client.contact.full_name
    assert_text @assignment3.client.contact.full_name
    refute_text @assignment1.client.contact.full_name
  end

  test 'enter_client_search_text_brings_suggestions' do
    fill_autocomplete 'q[client_contact_full_name_cont]', with: 'R', items_expected: 2,
      check_items: [@assignment2.client.contact.full_name, @assignment3.client.contact.full_name]
  end

  test 'suggestions client search triggers the search correctly' do
    fill_autocomplete 'q[client_contact_full_name_cont]', with: 'Pon'
    click_button 'Klient/innen Suchen'
    visit current_url
    within 'tbody' do
      assert_text @assignment1.client.contact.full_name
      assert_equal 1, find_all('tr').size
    end
  end

  test 'searching for a client, does not mix up with volunteers name' do
    fill_autocomplete 'q[client_contact_full_name_cont]', with: 'er', items_expected: 1,
      check_items: [@assignment3.client.contact.full_name]
  end
end
