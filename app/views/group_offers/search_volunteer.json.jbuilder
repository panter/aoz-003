json.array!(@volunteers) do |volunteer|
  json.data do
    json.search volunteer.contact.full_name
  end
  json.value volunteer.contact.full_name
end
