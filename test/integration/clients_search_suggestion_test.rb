require 'test_helper'

class ClientsSearchSuggestionTest < ActionDispatch::IntegrationTest
  test 'clients suggest json result is correct' do
    superadmin = create :user
    clients = ('a'..'e').to_a.map do |letter|
      client_one = create :client
      client_one.contact.update(first_name: (letter * 5) + client_one.contact.first_name)
      client_two = create :client
      client_two.contact.update(last_name: (letter * 5) + client_two.contact.last_name)
      [client_one, client_two]
    end
    login_as superadmin
    get search_clients_path, as: :json, params: { q: { contact_full_name_cont: 'aaa' } }
    results = JSON.parse response.body
    assert_equal 2, results.size
    results.map { |result| result['value'] }.each do |result|
      assert_includes clients.first.map { |client| client.contact.full_name }, result
      refute_includes clients.last.map { |client| client.contact.full_name }, result
    end
  end
end
