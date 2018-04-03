require 'application_system_test_case'

class UserSearchesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @superadmin.profile.contact.update(first_name: 'Walter', last_name: 'White')

    @volunteer = create :user_volunteer
    @volunteer.profile.contact.update(first_name: 'Jesse', last_name: 'Pinkman')

    @social_worker = create :user, role: 'social_worker'
    @social_worker.profile.contact.update(first_name: 'Skyler', last_name: 'White')

    @department_manager = create :user, role: 'department_manager',
      email: 'better_call_saul@good.man'
    @department_manager.profile.really_destroy!

    login_as @superadmin
    visit users_path
  end

  test 'basic_non_suggests_search_works' do
    fill_in name: 'q[full_name_cont]', with: 'Whi'
    click_button 'Suchen'
    assert page.has_text? @superadmin.full_name
    assert page.has_text? 'Superadmin'
    assert page.has_text? @social_worker.full_name
    assert page.has_text? 'Sozialarbeiter/in'
    refute page.has_text? @volunteer.full_name
    refute page.has_text? 'Freiwillige/r'
    refute page.has_text? @department_manager.full_name
    refute page.has_text? 'Freiwilligenverantwortliche/r'
  end

  # with this test we check if the suggestions are correct, we don't check what happens in the body section,
  # because travis selects somehow the first  suggestion and then we run into errors.
  test 'enter_search_text_brings_suggestions' do
    fill_autocomplete 'q[full_name_cont]', with: 'Whi', items_expected: 2,
      check_item: [@superadmin.full_name, @social_worker.full_name]
  end

  test 'user with no profile is searchable with email' do
    fill_in name: 'q[full_name_cont]', with: 'saul'
    click_button 'Suchen'

    within 'tbody' do
      refute page.has_text? @department_manager.full_name
      assert_equal @department_manager.email, 'better_call_saul@good.man'
      assert page.has_text? 'Freiwilligenverantwortliche/r'
      assert page.has_link? @department_manager.email

      refute page.has_text? @superadmin.full_name
      refute page.has_text? 'Superadmin'
      refute page.has_text? @social_worker.full_name
      refute page.has_text? 'Sozialarbeiter/in'
      refute page.has_text? @volunteer.full_name
      refute page.has_text? 'Freiwillige/r'
    end
  end
end
