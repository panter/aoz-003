json.array!(@group_offers) do |group_offer|
  json.id group_offer.id
  json.volunteers group_offer.volunteer_contacts.pluck(:full_name).select { |name| name.match(/#{params[:term]}/i) }
  json.label group_offer.volunteer_contacts.pluck(:full_name).select { |name| name.match(/#{params[:term]}/i) }.join('; ') + \
    " – #{group_offer.title}"
  json.value group_offer.volunteer_contacts.pluck(:full_name).select { |name| name.match(/#{params[:term]}/i) }
end
