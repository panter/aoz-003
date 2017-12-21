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

  def map_assignment_state(from_date, to_date)
    return 'suggested' if from_date > now
    return 'active' if from_date < now && to_date.nil? || to_date > now
    return 'archived' if to_date < now.years_ago(3)
    'finished'
  end
end
