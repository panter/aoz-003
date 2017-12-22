class GroupOfferTransform < Transformer
  # could be needed relations

  def prepare_attributes(group_offer_category, group_offer_fields)
    {
      title: group_offer_fields[:title],
      description: group_offer_fields[:title],
      location: group_offer_fields[:location],
      schedule_details: nil,
      group_offer_category: group_offer_category,
      creator: @ac_import.import_user,
      import_attributes: access_import(:no_table_reference, nil, kurs: nil)
    }
  end

  def get_or_create_by_import(group_assignments, *group_offer_fields)
    group_offer_category = GroupOfferCategory.find_or_create_by(
      category_name: FREIWILLIGEN_FUNKTION[
        group_assignments.first.import.store['freiwilligen_einsatz']['fk_FreiwilligenFunktion']
      ]
    )
    group_offer = GroupOffer.new(prepare_attributes(group_offer_category, *group_offer_fields))
    group_offer.group_assignments = group_assignments
    group_offer.department = find_group_offer_department(group_offer.group_assignments)
    group_offer.save!
    group_offer
  end

  def import_multiple(fw_einsaetze)
    group_assignments = @ac_import.group_assignment_transform.import_all(einsaetze: fw_einsaetze)
    grouped_group_assignments(group_assignments).map do |group_offer_title, group_assignments|
      location = group_assignments.first.import.store['freiwilligen_einsatz']['t_EinsatzOrt']
      discription = group_assignments.map { |ga| ga.import.store['freiwilligen_einsatz']['m_Beschreibung'] }.join(";\n")
      title = group_assignments.first.import.store['freiwilligen_einsatz']['t_Kurzbezeichnung']
      get_or_create_by_import(group_assignments, location: location, discription: discription, title: title)
    end
  end

  def grouped_group_assignments(group_assignments)
    group_assignments.group_by do |group_assignment|
      group_assignment.import.store['freiwilligen_einsatz']['t_Kurzbezeichnung']
    end
  end

  def find_group_offer_department(group_assignments)
    return if einsatz_ort_ids(group_assignments).compact.blank?
    binding.pry if einsatz_ort_ids(group_assignments).compact.uniq.size > 1
    @ac_import.department_transform.get_or_create_by_import(
      einsatz_ort_ids(group_assignments).compact.uniq.first
    )
  end

  def einsatz_ort_ids(group_assignments)
    @einsatz_ort_ids ||= group_assignments.map do |group_assignment|
      group_assignment.import.store['freiwilligen_einsatz']['fk_EinsatzOrt']
    end
  end


  def import_all(fw_einsaetze = nil)
    import_multiple(fw_einsaetze || @freiwilligen_einsaetze.where_animation_f)
  end
end
