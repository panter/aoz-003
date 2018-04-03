json.array!(@assignments) do |assignment|
  json.id assignment.client.id
  json.label assignment.client.contact.full_name
  json.value assignment.client.contact.full_name
end
