json.array!(@assignments) do |assignment|
  json.id assignment.volunteer.id
  json.label assignment.volunteer.contact.full_name
  json.value assignment.volunteer.contact.full_name
end
