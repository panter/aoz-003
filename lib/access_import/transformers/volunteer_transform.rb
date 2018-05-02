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
    haupt_person = @haupt_person.find(personen_rolle[:fk_Hauptperson]) || {}
    original_email = haupt_person[:email]
    {
      salutation: haupt_person[:salutation],
      birth_year: haupt_person[:d_Geburtsdatum],
      nationality: haupt_person[:nationality],
      accepted_at: personen_rolle[:d_Rollenbeginn],
      resigned_at: personen_rolle[:d_Rollenende],
      registrar: @ac_import.import_user,
      acceptance: :accepted,
      intro_course: true,
      waive: personen_rolle[:b_SpesenVerzicht] == 1
    }.merge(prepare_kontoangaben(personen_rolle[:fk_Hauptperson]))
      .merge(language_skills_attributes(haupt_person[:sprachen]))
      .merge(contact_attributes(haupt_person.merge(email: import_time_email)))
      .merge(import_attributes(:tbl_Personenrollen, personen_rolle[:pk_PersonenRolle],
        personen_rolle: personen_rolle, haupt_person: haupt_person.merge(email: original_email)))
  end

  def get_or_create_by_import(personen_rollen_id, personen_rolle = nil)
    volunteer = get_import_entity(:volunteer, personen_rollen_id)
    return volunteer if volunteer.present?
    personen_rolle ||= @personen_rolle.find(personen_rollen_id)
    return nil if personen_rolle[:d_Rollenende].present? && personen_rolle[:d_Rollenende] < Time.zone.now
    binding.pry if personen_rolle[:d_Rollenende].present?
    volunteer = Volunteer.new(prepare_attributes(personen_rolle))
    volunteer.save!(validate: false)
    update_timestamps(volunteer, personen_rolle[:d_Rollenbeginn], personen_rolle[:d_MutDatum])
  end

  def default_all
    @personen_rolle.all_volunteers
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
