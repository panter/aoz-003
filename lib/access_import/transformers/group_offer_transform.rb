class GroupOfferTransform < Transformer
  # could be needed relations

  def prepare_attributes(group_offer_category, group_offer_fields)
    {
      title: group_offer_fields[:title],
      description: group_offer_fields[:title],
      location: group_offer_fields[:location],
      schedule_details: nil,
      group_offer_category: group_offer_category,
      creator: @ac_import.import_user
    }.merge(import_attributes(:no_table_reference, nil, kurs: nil))
  end

  def get_or_create_by_import(group_assignments, *group_offer_fields)
    group_offer = GroupOffer.new(
      prepare_attributes(create_category(group_assignments), *group_offer_fields)
    )
    group_offer.department = find_group_offer_department(group_assignments)
    group_offer.group_assignments = filter_non_unique_volunteer(group_assignments)
    group_offer.save!(validate: false)
    handle_termination_and_update(group_offer)
  end

  def import_multiple(fw_einsaetze)
    fetched_gas = @ac_import.group_assignment_transform.import_all(einsaetze: fw_einsaetze)
    grouped_group_assignments(fetched_gas).map do |_, group_assignments|
      location = group_assignments.first.import.store['freiwilligen_einsatz']['t_EinsatzOrt']
      offers_assignments = group_assignments.find_all { |ga| ga.group_offer_id.blank? }
      next if offers_assignments.blank?
      title = offers_assignments.first.import.store['freiwilligen_einsatz']['t_Kurzbezeichnung']
      get_or_create_by_import(
        offers_assignments, location: location, title: title,
        discription: group_assignments
                       .map { |ga| ga.import.store['freiwilligen_einsatz']['m_Beschreibung'] }
                       .join(";\n")
      )
    end
  end

  def default_all
    @freiwilligen_einsaetze.where_animation_f
  end

  def create_category(group_assignments)
    GroupOfferCategory.find_or_create_by(category_name: FREIWILLIGEN_FUNKTION[
        group_assignments.first.import.store['freiwilligen_einsatz']['fk_FreiwilligenFunktion']
      ])
  end

  def handle_termination_and_update(group_offer)
    if group_offer.group_assignments.any? && group_offer.group_assignments.unterminated.blank?
      end_time = group_offer.group_assignments.maximum(:period_end)
      group_offer.assign_attributes(period_end: end_time,
        period_end_set_by: @ac_import.import_user)
    end
    group_offer.group_assignments.each do |ga|
      ga.assign_attributes(updated_at: ga.import.store['freiwilligen_einsatz']['d_MutDatum'])
    end
    start_time = group_offer.group_assignments.minimum(:period_start)
    group_offer.period_start = start_time
    update_timestamps(group_offer, start_time, group_offer.group_assignments.maximum(:updated_at))
  end

  def filter_non_unique_volunteer(group_assignments)
    return group_assignments if group_assignments.size < 2
    group_assignments.group_by(&:volunteer).flat_map do |_, g_assignments|
      not_terminated = g_assignments.find_all { |ga| !ga.terminated? }.sort_by(&:updated_at)
      [not_terminated.pop] + g_assignments.find_all(&:terminated?) +
        not_terminated.map do |ga|
          ga.import_terminate(@ac_import.import_user, ga.period_end || Time.zone.now)
          ga
        end
    end.compact
  end

  def grouped_group_assignments(group_assignments)
    group_assignments.compact.group_by do |group_assignment|
      group_assignment.import.store['freiwilligen_einsatz']['t_Kurzbezeichnung']
    end
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
end
