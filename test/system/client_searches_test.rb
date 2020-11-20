require 'application_system_test_case'

class ClientSearchesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @clients = ('a'..'e').to_a.map do |letter|
      client_one = create :client
      client_one.contact.update(first_name: (letter * 5) + client_one.contact.first_name)
      client_two = create :client
      client_two.contact.update(last_name: (letter * 5) + client_two.contact.last_name)
      [letter.to_sym, [client_one, client_two]]
    end.to_h
    login_as @superadmin
    visit clients_path
  end

  test 'basic_non_suggests_search_works' do
    fill_in name: 'q[contact_full_name_cont]', with: 'eee'
    wait_for_ajax
    find_field(name: 'q[contact_full_name_cont]').native.send_keys(:tab, :enter)
    assert_text @clients[:e].first.contact.full_name
    assert_text @clients[:e].last.contact.full_name
  end

  test 'enter_search_text_brings_suggestions' do
    fill_in name: 'q[contact_full_name_cont]', with: 'aaa'
    wait_for_ajax
    within '.autocomplete-suggestions' do
      assert_text @clients[:a].first.contact.full_name, normalize_ws: true
      assert_text @clients[:a].last.contact.full_name, normalize_ws: true
      refute_text @clients[:b].first.contact.full_name, normalize_ws: true,
                                                        wait: 0
      refute_text @clients[:b].last.contact.full_name, normalize_ws: true,
                                                       wait: 0
    end
  end

  test 'suggestions search triggers the search correctly' do
    fill_in name: 'q[contact_full_name_cont]', with: 'aaa'
    wait_for_ajax
    find_field(name: 'q[contact_full_name_cont]').native.send_keys(:tab, :enter)
    visit current_url
    within 'tbody' do
      assert page.has_text?(@clients[:a][0].contact.full_name) ||
        page.has_text?(@clients[:a][1].contact.full_name)
      assert_equal 2, find_all('tr').size
    end
  end
end
