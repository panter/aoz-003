class GroupAssignmentTransform < Transformer
  # could be needed relations

  def prepare_attributes(einsatz, volunteer)
    {
      period_end: einsatz[:d_EinsatzBis],
      period_start: einsatz[:d_EinsatzVon],
      volunteer: volunteer,
      import_attributes: access_import(:tbl_FreiwilligenEinsätze, einsatz[:pk_FreiwilligenEinsatz],
        freiwilligen_einsatz: einsatz)
    }
  end

  def get_or_create_by_import(einsatz_id, einsatz: nil, group_offer: nil)
    einsatz ||= @freiwilligen_einsaetze.find(einsatz_id)
    group_assignment = Import.get_imported(GroupAssignment, einsatz_id)
    return group_assignment if group_assignment.present?
    volunteer = @ac_import.volunteer_transform.get_or_create_by_import(einsatz[:fk_PersonenRolle])
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
