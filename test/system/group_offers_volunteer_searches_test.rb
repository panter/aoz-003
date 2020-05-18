require 'application_system_test_case'

class GroupOffersVolunteerSearchesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @volunteer_one = create :volunteer
    @volunteer_one.contact.update(first_name: 'Walter', last_name: 'White')
    @volunteer_two = create :volunteer
    @volunteer_two.contact.update(first_name: 'Jesse', last_name: 'Pinkman')
    @volunteer_three = create :volunteer
    @volunteer_three.contact.update(first_name: 'Skyler', last_name: 'White')
    @group_offer_one = create :group_offer, title: 'group_offer_one'
    create :group_assignment, volunteer: @volunteer_one, group_offer: @group_offer_one
    create :group_assignment, volunteer: @volunteer_three, group_offer: @group_offer_one
    @group_offer_two = create :group_offer, title: 'group_offer_two'
    create :group_assignment, volunteer: @volunteer_two, group_offer: @group_offer_two
    login_as @superadmin
    visit group_offers_path
  end

  test 'basic_non_suggests_search_works' do
    fill_in name: 'q[search_volunteer_cont]', with: 'Whi'
    wait_for_ajax
    page.find_field(name: 'q[search_volunteer_cont]').native.send_keys(:tab, :enter)
    assert page.has_text? @volunteer_one.contact.full_name
    assert page.has_text? @volunteer_three.contact.full_name
    assert page.has_text? @group_offer_one.title
    refute page.has_text? @volunteer_two.contact.full_name, wait: 1
    refute page.has_text? @group_offer_two.title, wait: 1
  end

  test 'enter_search_text_brings_suggestions' do
    fill_autocomplete 'q[search_volunteer_cont]', with: 'Whi', items_expected: 1,
      check_item: @group_offer_one.title
  end

  test 'suggestions search triggers the search correctly' do
    fill_autocomplete 'q[search_volunteer_cont]', with: 'Wal'
    wait_for_ajax
    page.find_field(name: 'q[search_volunteer_cont]').native.send_keys(:tab, :enter)
    visit current_url
    within 'tbody' do
      assert page.has_text? @volunteer_one.contact.full_name
      assert page.has_text? @group_offer_one.title
      refute page.has_text? @volunteer_two.contact.full_name, wait: 1
      assert_equal 1, find_all('tr').size
    end
  end
end
