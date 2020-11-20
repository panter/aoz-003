require 'application_system_test_case'

class UserSearchesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @superadmin.profile.contact.update(first_name: 'Walter', last_name: 'White')

    @volunteer = create(:volunteer).user

    @volunteer.volunteer.contact.update(first_name: 'Jesse', last_name: 'Pinkman')

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
    wait_for_ajax
    find_field(name: 'q[full_name_cont]').native.send_keys(:tab, :enter)
    visit current_url
    assert_text @superadmin.full_name
    assert_text @social_worker.full_name
    refute_text @volunteer.full_name, wait: 0
    refute_text @department_manager.full_name, wait: 0
  end

  # TODO: Flappy test
  # with this test we check if the suggestions are correct, we don't check
  # what happens in the body section,
  # because travis selects somehow the first  suggestion and then we run into errors.
  test 'enter_search_text_brings_suggestions' do
    fill_in name: 'q[full_name_cont]', with: 'Whi'
    wait_for_ajax
    within '.autocomplete-suggestions' do
      assert_text "#{@superadmin.full_name}; #{@superadmin.email}"\
                  " - #{I18n.t("role.#{@superadmin.role}")}",
                  normalize_ws: true
      refute_text "#{@volunteer.full_name}; #{@volunteer.email}"\
                  " - #{I18n.t("role.#{@volunteer.role}")}",
                  normalize_ws: true,
                  wait: 0
    end
  end

  test 'user with no profile is searchable with email' do
    fill_in name: 'q[full_name_cont]', with: 'saul'
    wait_for_ajax
    find_field(name: 'q[full_name_cont]').native.send_keys(:tab, :enter)

    within 'tbody' do
      assert_link @department_manager.email
      refute_text @superadmin.full_name, wait: 0
      refute_text @social_worker.full_name, wait: 0
      refute_text @volunteer.full_name, wait: 0
    end
  end
end
