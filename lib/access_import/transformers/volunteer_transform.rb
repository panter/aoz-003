class VolunteerTransform < Transformer
  # could be needed relations
  #
  # k_traeger = @kosten_traeger.find(personen_rolle[:fk_Kostenträger])
  # journals = @journale.where_haupt_person(haupt_person[:pk_Hauptperson])
  # einsaetze = @fw_einsaetze.where_personen_rolle(personen_rolle[:pk_PersonenRolle])
  # entschaedigungen = @fw_entschaedigung.where_personen_rolle(personen_rolle[:pk_PersonenRolle])
  # konto_angaben = @konto_angaben.where_haupt_person(haupt_person[:pk_Hauptperson])
  # stunden_erfassungen = @stundenerfassung.where_personen_rolle(personen_rolle[:pk_PersonenRolle])
  #
  def prepare_attributes(personen_rolle)
    haupt_person = @haupt_person.find(personen_rolle[:fk_Hauptperson])
    original_email = haupt_person[:email]
    {
      salutation: haupt_person[:salutation],
      birth_year: haupt_person[:d_Geburtsdatum],
      nationality: haupt_person[:nationality],
      accepted_at: personen_rolle[:d_Rollenbeginn],
      registrar: @ac_import.import_user
    }.merge(prepare_kontoangaben(personen_rolle[:fk_Hauptperson]))
      .merge(language_skills_attributes(haupt_person[:sprachen]))
      .merge(contact_attributes(haupt_person.merge(email: import_time_email)))
      .merge(import_attributes(:tbl_Personenrollen, personen_rolle[:pk_PersonenRolle],
        personen_rolle: personen_rolle,haupt_person: haupt_person.merge(email: original_email)))
  end

  def get_or_create_by_import(personen_rollen_id, personen_rolle = nil)
    return @entity if get_import_entity(:volunteer, personen_rollen_id).present?
    personen_rolle ||= @personen_rolle.find(personen_rollen_id)
    volunteer = Volunteer.create!(prepare_attributes(personen_rolle))
    handle_volunteer_state(volunteer, personen_rolle)
  end

  def import_multiple(personen_rollen)
    personen_rollen.map do |key, personen_rolle|
      get_or_create_by_import(key, personen_rolle)
    end
  end

  def import_all(personen_rollen = nil)
    import_multiple(personen_rollen || @personen_rolle.all_volunteers)
  end

  def handle_volunteer_state(volunteer, personen_rolle)
    period_end = personen_rolle[:d_Rollenende]
    if period_end.present?
      volunteer.resigned!
      volunteer.update(resigned_at: period_end)
    end
    update_timestamps(volunteer, personen_rolle[:d_Rollenbeginn], personen_rolle[:d_MutDatum])
  end

  def konto_angaben(haupt_person_id = nil)
    @konto_angabe ||= @kontoangaben.where_haupt_person(haupt_person_id)
  end

  def extract_numbers
    formats = { t_IBAN: 'IBAN: %s', t_PCKonto: 'PC-Konto: %s', t_Bankkonto: 'Bankkonto: %s',
                z_ClearingNummer: 'Clearing-Nummer: %s' }
    konto_angaben
      .slice(:t_IBAN, :t_PCKonto, :t_Bankkonto, :z_ClearingNummer)
      .compact
      .map { |key, number| formats[key] % number }
      .join('; ')
  end

  def prepare_kontoangaben(haupt_person_id)
    return {} if konto_angaben(haupt_person_id).blank?
    { iban: extract_numbers,
      bank: konto_angaben.values_at(:t_BankenName, :city, :m_Bemerkung).compact.join(', ') }
  end
end
