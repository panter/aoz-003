class KursTransform < Transformer
  # could be needed relations

  def prepare_attributes(kurs, group_offer_category)
    {
      title: kurs[:t_KursBezeichnung],
      description: kurs[:m_Beschreibung],
      location: kurs[:t_Ort],
      schedule_details: kurs[:t_Zeitraum],
      group_offer_category: group_offer_category,
      creator: @ac_import.import_user,
      import_attributes: access_import(:tbl_Kurse, kurs[:pk_Kurs], kurs: kurs)
    }
  end

  def get_or_create_by_import(kurs_id, kurs = nil)
    group_offer = get_import_entity(:group_offer, kurs_id)
    return group_offer if group_offer.present?
    kurs ||= @kurse.find(kurs_id)
    group_offer_category = @ac_import.kursart_transform.get_or_create_by_import(kurs[:fk_Kursart])
    group_offer = GroupOffer.new(prepare_attributes(kurs, group_offer_category))
    group_offer.group_assignments = fetch_group_assignments(kurs_id)
    group_offer.department = find_group_offer_department(group_offer.group_assignments)
    group_offer.save!
    group_offer
  end

  def find_group_offer_department(group_assignments)
    return if einsatz_ort_ids(group_assignments).compact.blank?
    @ac_import.department_transform.get_or_create_by_import(
      einsatz_ort_ids(group_assignments).compact.uniq.first
    )
  end

  def einsatz_ort_ids(group_assignments)
    @einsatz_ort_ids ||= group_assignments.map do |group_assignment|
      group_assignment.import.store['freiwilligen_einsatz']['fk_EinsatzOrt']
    end
  end

  def fetch_group_assignments(kurs_id)
    group_assignments = @ac_import.group_assignment_transform.import_all(
      einsaetze: @freiwilligen_einsaetze.where_kurs(kurs_id)
    )
    volunteer_ids = group_assignments.map(&:volunteer_id).uniq
    return group_assignments if volunteer_ids.size == group_assignments.size
    volunteer_ids.map do |volunteer_id|
      group_assignments.find { |group_assignment| group_assignment.volunteer_id == volunteer_id }
    end
  end

  def default_all
    @kurse.all
  end
end
