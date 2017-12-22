class AssignmentTransform < Transformer
  def prepare_attributes(fw_einsatz, client, volunteer, begleitet)
    {
      state: map_assignment_state(fw_einsatz[:d_EinsatzVon], fw_einsatz[:d_EinsatzBis]),
      client: client,
      volunteer: volunteer,
      period_start: fw_einsatz[:d_EinsatzVon],
      period_end: fw_einsatz[:d_EinsatzBis],
      performance_appraisal_review: fw_einsatz[:d_Standortgespräch],
      probation_period: fw_einsatz[:d_Probezeit],
      creator: @ac_import.import_user,
      home_visit: fw_einsatz[:d_Hausbesuch],
      first_instruction_lesson: fw_einsatz[:d_ErstUnterricht],
      short_description: fw_einsatz[:t_Kurzbezeichnung],
      goals: fw_einsatz[:m_Zielsetzung],
      starting_topic: fw_einsatz[:m_Einstiegsthematik],
      description: fw_einsatz[:m_Beschreibung],
      import_attributes: access_import(
        :tbl_FreiwilligenEinsätze, fw_einsatz[:pk_FreiwilligenEinsatz], fw_einsatz: fw_einsatz,
        begleitet: begleitet
      )
    }
  end

  def get_or_create_by_import(einsatz_id, fw_einsatz = nil)
    assignment = Import.get_imported(Assignment, einsatz_id)
    return assignment if assignment.present?
    volunteer = @ac_import.volunteer_transform.get_or_create_by_import(fw_einsatz[:fk_PersonenRolle])
    begleitet = @begleitete.find(fw_einsatz[:fk_Begleitete])
    client = @ac_import.client_transform.get_or_create_by_import(begleitet[:fk_PersonenRolle])
    parameters = prepare_attributes(fw_einsatz, client, volunteer, begleitet)
    assignment = Assignment.new(parameters)
    assignment.created_at = fw_einsatz[:d_EinsatzVon] || Time.zone.now
    assignment.save!
    assignment.delete if assignment.period_end.present? && assignment.period_end < 8.months.ago
  end

  def import_multiple(freiwilligen_einsaetze)
    freiwilligen_einsaetze.map do |key, fw_einsatz|
      get_or_create_by_import(key, fw_einsatz)
    end
  end

  def import_all(freiwilligen_einsaetze = nil)
    import_multiple(freiwilligen_einsaetze || @freiwilligen_einsaetze.where_begleitung)
  end

  def map_assignment_state(from_date, to_date)
    return 'suggested' if from_date > now
    return 'active' if from_date < now && to_date.nil? || to_date > now
    return 'archived' if to_date < now.years_ago(3)
    'finished'
  end
end
