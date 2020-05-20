json.array!(@group_offers) do |group_offer|
  json.data do
    json.category group_offer.active? ? 'Gruppenangebot Aktiv' : 'Gruppenangebot Inaktiv'
  end
  volunteers = group_offer.volunteer_contacts.pluck(:full_name).select do |name|
    name.match(/#{params[:term]}/i)
  end.join('; ')
  json.value "#{volunteers} – #{group_offer.title}"
end
