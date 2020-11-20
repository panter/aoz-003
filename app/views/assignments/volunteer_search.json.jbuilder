json.array!(@assignments) do |assignment|
  json.data do
    json.category assignment.active? ? 'Tandem Aktiv' : 'Tandem Inaktiv'
    json.search assignment.volunteer.contact.full_name
  end
  context_info = if assignment.period_start && !assignment.period_end
                   " - Einsatzstart: #{l(assignment.period_start)}"
                 elsif assignment.period_end
                   " - Einsatzende: #{l(assignment.period_start)}"
                 end
  json.value "#{assignment.volunteer.contact.full_name}#{context_info}"
end
