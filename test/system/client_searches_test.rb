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
    click_button 'Suchen'
    assert page.has_text? @clients.last.first.contact.full_name
    assert page.has_text? @clients.last.last.contact.full_name
  end

  test 'enter_search_text_brings_suggestions' do
    fill_autocomplete 'q[contact_full_name_cont]', with: 'zzzz'
    # fill_in name: 'q[contact_full_name_cont]', with: 'zzzz'
    assert false
    assert page.has_text? @clients.last.first.contact.full_name
    assert page.has_text? @clients.last.last.contact.full_name
  end

end
