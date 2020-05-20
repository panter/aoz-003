json.array!(@clients) do |client|
  json.data do
    json.category client.t_enum(:acceptance)
    json.search client.contact.full_name
  end
  json.value client.contact.full_name
end
