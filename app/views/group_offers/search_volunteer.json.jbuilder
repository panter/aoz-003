json.array!(@volunteers) do |volunteer|
  json.data volunteer.id
  json.value volunteer.contact.full_name
end
