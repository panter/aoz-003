require 'application_system_test_case'

class VolunteerSearchesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @volunteers = ('a'..'e').to_a.map do |letter|
      volunteer_one = create :volunteer
      volunteer_one.contact.update(first_name: (letter * 5) + volunteer_one.contact.first_name)
      volunteer_two = create :volunteer
      volunteer_two.contact.update(last_name: (letter * 5) + volunteer_two.contact.last_name)
      [letter.to_sym, [volunteer_one, volunteer_two]]
    end.to_h
    login_as @superadmin
    visit volunteers_path
  end

  test 'basic_non_suggests_search_works' do
    fill_in name: 'q[contact_full_name_cont]', with: 'eeee'
    wait_for_ajax
    page.find_field(name: 'q[contact_full_name_cont]').native.send_keys(:tab, :enter)
    wait_for_ajax
    assert_text @volunteers[:e].first.contact.full_name, normalize_ws: true
    assert_text @volunteers[:e].last.contact.full_name, normalize_ws: true
  end

  test 'enter_search_text_brings_suggestions' do
    fill_in 'q[contact_full_name_cont]', with: 'aaaa'
    wait_for_ajax
    within '.autocomplete-suggestions' do
      assert_text @volunteers[:a].first.contact.full_name, normalize_ws: true
      assert_text @volunteers[:a].last.contact.full_name, normalize_ws: true
      refute_text @volunteers[:b].first.contact.full_name, normalize_ws: true,
                                                           wait: 0
      refute_text @volunteers[:b].last.contact.full_name, normalize_ws: true,
                                                          wait: 0
    end
  end

  test 'suggestions search triggers the search correctly' do
    fill_in name: 'q[contact_full_name_cont]', with: 'aaaa'
    wait_for_ajax
    page.find_field(name: 'q[contact_full_name_cont]').native.send_keys(:tab, :enter)
    wait_for_ajax
    within 'tbody' do
      assert page.has_text?(@volunteers[:a][0].contact.full_name) || page.has_text?(@volunteers[:a][1].contact.full_name)
      assert_equal 2, find_all('tr').size
    end
  end
end
