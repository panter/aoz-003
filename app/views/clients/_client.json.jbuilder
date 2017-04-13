json.extract! client, :id, :firstname, :lastname, :created_at, :updated_at
json.url client_url(client, format: :json)
