json.array!(@clients) do |client|
  json.data do
    json.category client.t_enum(:acceptance)
  end
  json.value client.contact.full_name
end
