class HourTransform < Transformer
  def prepare_attributes(erfassung, hourable, volunteer)
    {
      hourable: hourable,
      volunteer: get_volunteer(erfassung),
      hours: erfassung[:z_Stundenzahl],
      meeting_date: erfassung[:d_MutDatum]
    }
  end

  def get_or_create_by_import(erfassung_id, erfassung = nil)
    hour = Import.get_imported(Hour, erfassung_id)
    return hour if hour.present?
    erfassung ||= @stundenerfassung.find(erfassung_id)
    hourable = get_hourable(erfassung)
    volunteer = get_volunteer(erfassung)
    return if hourable.blank? || volunteer.blank?
    hour = Hour.create(prepare_attributes(erfassung, hourable, volunteer))
    hour.save
    hour.update(created_at: hour.meeting_date, updated_at: hour.meeting_date)
    hour
  end

  def import_all
    @stundenerfassung.all.each do |key, erfassung|
      get_or_create_by_import(key, erfassung)
    end
  end

  def get_hourable(erfassung)
    einsatz = @freiwilligen_einsaetze.find(erfassung[:fk_FreiwilligenEinsatz])
    return if einsatz.blank?
    if einsatz[:fk_FreiwilligenFunktion] == 1
      get_assignment(erfassung[:fk_FreiwilligenEinsatz], einsatz)
    else
      get_group_assignment(erfassung[:fk_FreiwilligenEinsatz])
    end
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
