json.array!(@volunteers) do |volunteer|
  json.id volunteer.id
  json.label volunteer.contact.full_name
  json.value volunteer.contact.full_name
end
