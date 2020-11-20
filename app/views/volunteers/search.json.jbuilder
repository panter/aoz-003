json.array!(@volunteers) do |volunteer|
  json.data do
    json.category volunteer.t_enum(:acceptance)
    json.search volunteer.contact.full_name
  end
  json.value volunteer.contact.full_name
end
