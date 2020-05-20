json.array!(@volunteers) do |volunteer|
  json.data do
    json.category volunteer.t_enum(:acceptance)
  end
  json.value volunteer.contact.full_name
end
