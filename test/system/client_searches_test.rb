require 'application_system_test_case'

class ClientSearchesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @clients = ('a'..'z').to_a.map do |letter|
      client_one = create :client
      client_one.contact.update(first_name: (letter * 5) + client_one.contact.first_name)
      client_two = create :client
      client_two.contact.update(last_name: (letter * 5) + client_two.contact.last_name)
      [client_one, client_two]
    end
    login_as @superadmin
    visit clients_path
  end

  test 'basic_non_suggests_search_works' do
    fill_in name: 'q[contact_full_name_cont]', with: 'zzzz'
    wait_for_ajax
    find_field(name: 'q[contact_full_name_cont]').native.send_keys(:tab, :enter)
    assert_text @clients.last.first.contact.full_name
    assert_text @clients.last.last.contact.full_name
  end

  test 'enter_search_text_brings_suggestions' do
    fill_autocomplete(
      'q[contact_full_name_cont]',
      with: 'aaa',
      items_expected: 2,
      check_items: [@clients.first[0].contact.full_name, @clients.first[1].contact.full_name]
    )
  end

  test 'suggestions search triggers the search correctly' do
    fill_autocomplete 'q[contact_full_name_cont]', with: 'aaa'
    wait_for_ajax
    find_field(name: 'q[contact_full_name_cont]').native.send_keys(:tab, :enter)
    visit current_url
    within 'tbody' do
      assert page.has_text?(@clients.first[0].contact.full_name) ||
        page.has_text?(@clients.first[1].contact.full_name)
      assert_equal 1, find_all('tr').size
    end
  end
end
