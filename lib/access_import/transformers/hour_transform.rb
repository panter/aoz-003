class HourTransform < Transformer
  def prepare_attributes(erfassung, hourable, volunteer)
    {
      hourable: hourable,
      volunteer: volunteer,
      hours: erfassung[:z_Stundenzahl],
      meeting_date: erfassung[:d_MutDatum]
    }.merge(import_attributes(:tbl_Stundenerfassung, erfassung[:pk_Stundenerfassung],
                              erfassung: erfassung))
  end

  def get_or_create_by_import(erfassung_id, erfassung = nil)
    hour = get_import_entity(:hour, erfassung_id)
    return hour if hour.present?

    erfassung ||= @stundenerfassung.find(erfassung_id)
    return if erfassung[:z_Stundenzahl] <= 0

    hourable = get_hourable(erfassung)
    return if hourable.blank? || hourable.deleted?

    volunteer = get_volunteer(erfassung)
    return if volunteer.blank? || volunteer.deleted?

    hour = Hour.create!(prepare_attributes(erfassung, hourable, volunteer))
    update_timestamps(hour, hour.meeting_date)
  end

  def import_multiple(erfassungen)
    erfassungen.map do |key, erfassung|
      get_or_create_by_import(key, erfassung)
    end
    bind_imported_hours_to_dummy_billing_expense
  end

  def import_for_personen_rolle(personen_rolle_id)
    import_multiple(@stundenerfassung.where_personen_rolle(personen_rolle_id))
  end

  def default_all
    @stundenerfassung.all
  end

  def bind_imported_hours_to_dummy_billing_expense
    Volunteer.joins(hours: :import)
      .where('hours.billing_expense_id IS NULL')
      .map { |volunteer| mark_hours_unbillable(volunteer) }
  end

  def mark_hours_unbillable(volunteer)
    billing_expense = BillingExpense.new(volunteer: volunteer, user: @ac_import.import_user,
      hours: volunteer.hours, iban: volunteer.iban, bank: volunteer.bank, amount: 0)
    billing_expense.import_mode = true
    billing_expense.save!
    billing_expense.update(created_at: billing_expense.hours.maximum(:created_at),
      updated_at: billing_expense.hours.maximum(:created_at))
    hours = billing_expense.hours.map do |hour|
      hour.update(updated_at: billing_expense.created_at)
      hour
    end
    billing_expense.delete
    hours
  end

  def get_hourable(erfassung)
    einsatz = @freiwilligen_einsaetze.find(erfassung[:fk_FreiwilligenEinsatz])
    return if einsatz.blank?
    if einsatz[:fk_FreiwilligenFunktion] == 1
      return get_assignment(erfassung[:fk_FreiwilligenEinsatz], einsatz)
    end

    get_group_assignment(erfassung[:fk_FreiwilligenEinsatz]).group_offer
  end

  def get_assignment(einsatz_id, einsatz)
    @ac_import.assignment_transform.get_or_create_by_import(einsatz_id, einsatz)
  end

  def get_group_assignment(einsatz_id)
    @ac_import.group_assignment_transform.get_or_create_by_import(einsatz_id)
  end

  def get_volunteer(erfassung)
    pers_rolle = @personen_rolle.find(erfassung[:fk_PersonenRolle])
    return if pers_rolle.blank?

    @ac_import.volunteer_transform.get_or_create_by_import(erfassung[:fk_PersonenRolle], pers_rolle)
  end
end
