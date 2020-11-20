json.array!(@group_offers) do |group_offer|
  volunteers = group_offer.volunteer_contacts.pluck(:full_name).select do |name|
    name.match(/#{params[:q][:search_volunteer_cont]}/i)
  end.join('; ')
  json.data do
    json.search volunteers
  end
  json.value "#{volunteers} – #{group_offer.title}"
end
