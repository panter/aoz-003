require 'application_system_test_case'

class ClientSearchesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @clients = ('a'..'f').to_a.map do |letter|
      client_one = create :client
      client_one.contact.update(last_name: letter * 5 + client_one.contact.last_name)
      client_two = create :client
      client_two.contact.update(last_name: letter * 5 + client_two.contact.last_name)
      [client_one, client_two]
    end
  end

  test 'enter search text brings suggestions' do
    login_as @superadmin
    visit clients_path
    fill_in 'Suche', with: 'aaaa'
    assert page.has_text? @clients[0][0].contact.last_name
    assert page.has_text? @clients[0][1].contact.last_name
  end
end
