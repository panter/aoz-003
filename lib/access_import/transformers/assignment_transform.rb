class AssignmentTransform < Transformer
  def prepare_attributes(fw_einsatz, client, volunteer, begleitet)
    {
      creator: @ac_import.import_user,
      client: client,
      volunteer: volunteer,
      period_start: fw_einsatz[:d_EinsatzVon],
      period_end: fw_einsatz[:d_EinsatzBis],
      performance_appraisal_review: fw_einsatz[:d_Standortgespräch],
      probation_period: fw_einsatz[:d_Probezeit],
      home_visit: fw_einsatz[:d_Hausbesuch],
      first_instruction_lesson: fw_einsatz[:d_ErstUnterricht],
      progress_meeting: fw_einsatz[:d_Standortgespräch],
      short_description: fw_einsatz[:t_Kurzbezeichnung],
      description: fw_einsatz[:m_Beschreibung],
      goals: fw_einsatz[:m_Zielsetzung],
      starting_topic: fw_einsatz[:m_Einstiegsthematik]
    }.merge(handle_terminated(fw_einsatz))
      .merge(import_attributes(:tbl_FreiwilligenEinsätze, fw_einsatz[:pk_FreiwilligenEinsatz],
        fw_einsatz: fw_einsatz, begleitet: begleitet))
  end

  def handle_terminated(fw_einsatz)
    return {} if fw_einsatz[:d_EinsatzBis].blank?
    {
      period_end_set_by: @ac_import.import_user,
      termination_submitted_by: @ac_import.import_user,
      termination_verified_by: @ac_import.import_user,
      termination_submitted_at: fw_einsatz[:d_EinsatzBis],
      termination_verified_at: fw_einsatz[:d_EinsatzBis]
    }
  end

  def get_or_create_by_import(einsatz_id, fw_einsatz = nil)
    assignment = get_import_entity(:assignment, einsatz_id)
    return assignment if assignment.present?
    fw_einsatz ||= @freiwilligen_einsaetze.find(einsatz_id)
    return if fw_einsatz.blank?
    volunteer ||= @ac_import.volunteer_transform.get_or_create_by_import(fw_einsatz[:fk_PersonenRolle])
    return if volunteer.blank?
    begleitet = @begleitete.find(fw_einsatz[:fk_Begleitete])
    client = @ac_import.client_transform.get_or_create_by_import(begleitet[:fk_PersonenRolle])
    return if client.blank?
    parameters = prepare_attributes(fw_einsatz, client, volunteer, begleitet)
    assignment = Assignment.new(parameters)
    assignment.save!(validate: false)
    update_timestamps(assignment, fw_einsatz[:d_MutDatum])
  end

  def default_all
    @freiwilligen_einsaetze.where_begleitung
  end
end
