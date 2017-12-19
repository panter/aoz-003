require 'application_system_test_case'

class AssignmentsVolunteerSearchesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @volunteer_one = create :volunteer
    @volunteer_one.contact.update(first_name: 'Walter', last_name: 'White')
    @volunteer_two = create :volunteer
    @volunteer_two.contact.update(first_name: 'Jesse', last_name: 'Pinkman')
    @volunteer_three = create :volunteer
    @volunteer_three.contact.update(first_name: 'Skyler', last_name: 'White')
    @assignment_one = create :assignment, volunteer: @volunteer_one
    @assignment_two = create :assignment, volunteer: @volunteer_two
    @assignment_three = create :assignment, volunteer: @volunteer_three
    login_as @superadmin
    visit assignments_path
  end

  test 'basic_non_suggests_search_works' do
    fill_in name: 'q[volunteer_contact_full_name_cont]', with: 'Whi'
    click_button 'Suchen'
    assert page.has_text? @assignment_one.volunteer.contact.full_name
    assert page.has_text? @assignment_three.volunteer.contact.full_name
    refute page.has_text? @assignment_two.volunteer.contact.full_name
  end

  test 'enter_search_text_brings_suggestions' do
    fill_autocomplete 'q[volunteer_contact_full_name_cont]', with: 'Whi', items_expected: 2,
      check_items: [@assignment_one.volunteer.contact.full_name, @assignment_three.volunteer.contact.full_name]
  end

  test 'suggestions search triggers the search correctly' do
    fill_autocomplete 'q[volunteer_contact_full_name_cont]', with: 'Wal'
    click_button 'Suchen'
    visit current_url
    within 'tbody' do
      assert page.has_text? @assignment_one.volunteer.contact.full_name
      assert_equal 1, find_all('tr').size
    end
  end
end
