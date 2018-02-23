require 'application_system_test_case'

class VolunteerSearchesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @volunteers = ('a'..'z').to_a.map do |letter|
      volunteer_one = create :volunteer
      volunteer_one.contact.update(first_name: (letter * 5) + volunteer_one.contact.first_name)
      volunteer_two = create :volunteer
      volunteer_two.contact.update(last_name: (letter * 5) + volunteer_two.contact.last_name)
      [volunteer_one, volunteer_two]
    end
    login_as @superadmin
    visit volunteers_path
  end

  test 'basic_non_suggests_search_works' do
    fill_in name: 'q[contact_full_name_cont]', with: 'zzzz'
    click_button 'Suchen'
    assert page.has_text? @volunteers.last.first.contact.full_name
    assert page.has_text? @volunteers.last.last.contact.full_name
  end

  test 'enter_search_text_brings_suggestions' do
    fill_autocomplete 'q[contact_full_name_cont]', with: 'aaa', items_expected: 2,
      check_items: [@volunteers.first[0].contact.full_name, @volunteers.first[1].contact.full_name]
  end

  test 'suggestions search triggers the search correctly' do
    fill_autocomplete 'q[contact_full_name_cont]', with: 'aaa'
    click_button 'Suchen'
    visit current_url
    within 'tbody' do
      assert page.has_text?(@volunteers.first[0].contact.full_name) || page.has_text?(@volunteers.first[1].contact.full_name)
      assert_equal 1, find_all('tr').size
    end
  end
end
