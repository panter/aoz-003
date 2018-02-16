class GroupAssignmentTransform < Transformer
  # could be needed relations

  def prepare_attributes(einsatz, volunteer)
    {
      period_start: einsatz[:d_EinsatzVon],
      period_end: einsatz[:d_EinsatzBis],
      volunteer: volunteer,
      import_attributes: access_import(:tbl_FreiwilligenEinsätze, einsatz[:pk_FreiwilligenEinsatz],
        freiwilligen_einsatz: einsatz)
    }.merge(termination_attributes(einsatz))
  end

  def termination_attributes(einsatz)
    return {} if einsatz[:d_EinsatzBis].blank?
    {
      period_end_set_by: @ac_import.import_user,
      termination_submitted_by: @ac_import.import_user,
      termination_verified_by: @ac_import.import_user,
      termination_submitted_at: einsatz[:d_EinsatzBis],
      termination_verified_at: einsatz[:d_EinsatzBis],
      active: false
    }
  end

  def get_or_create_by_import(einsatz_id, einsatz: nil, group_offer: nil, volunteer: nil)
    return @entity if get_import_entity(:group_assignment, einsatz_id).present?
    einsatz ||= @freiwilligen_einsaetze.find(einsatz_id)
    volunteer ||= @ac_import.volunteer_transform.get_or_create_by_import(einsatz[:fk_PersonenRolle])
    group_assignment = GroupAssignment.new(prepare_attributes(einsatz, volunteer))
    return group_assignment if group_offer.blank?
    group_assignment.group_offer = group_offer
    group_assignment.save!
    group_assignment
  end

  def import_multiple(einsaetze, group_offer: nil)
    einsaetze.map do |key, einsatz|
      get_or_create_by_import(key, einsatz: einsatz, group_offer: group_offer)
    end
  end

  def import_all(einsaetze: nil, group_offer: nil)
    import_multiple(einsaetze || @freiwilligen_einsaetze.all, group_offer: group_offer)
  end
end
