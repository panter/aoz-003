json.array!(@clients) do |client|
  json.id client.id
  json.label client.contact.full_name
  json.value client.contact.full_name
end
