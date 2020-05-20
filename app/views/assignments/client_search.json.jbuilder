json.array!(@assignments) do |assignment|
  json.data do
    json.category assignment.active? ? 'Tandem Aktiv' : 'Tandem Inaktiv'
  end
  context_info = if assignment.active? && assignment.period_start
                   " - Einsatzstart: #{l(assignment.period_start)}"
                 elsif !assignment.active? && assignment.period_end
                   " - Einsatzende: #{l(assignment.period_start)}"
                 end
  json.value "#{assignment.client.contact.full_name}#{context_info}"
end
