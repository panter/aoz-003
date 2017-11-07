json.clients do
  json.array!(@clients) do |client|
    json.last_name client.contact.last_name
    json.first_name client.contact.first_name
    json.url client_path(client)
  end
end
