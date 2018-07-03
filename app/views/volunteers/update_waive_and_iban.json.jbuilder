json.volunteer do
  json.id @volunteer.id
  json.waive @volunteer.waive
  json.iban @volunteer.iban
  json.bank @volunteer.bank
  json.errors @volunteer.errors&.messages
end
