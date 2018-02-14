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
      language_skills_attributes: language_skills_attributes(haupt_person[:sprachen]),
      contact_attributes: contact_attributes(haupt_person.merge(email: "importiert#{Time.zone.now.to_f}@example.com")),
      registrar: @ac_import.import_user,
      import_attributes: access_import(
        :tbl_Personenrollen, personen_rolle[:pk_PersonenRolle], personen_rolle: personen_rolle,
        haupt_person: haupt_person.merge(email: original_email)
      )
    }.merge(prepare_kontoangaben(personen_rolle[:fk_Hauptperson]))
  end

  def get_or_create_by_import(personen_rollen_id, personen_rolle = nil)
    volunteer = Import.get_imported(Volunteer, personen_rollen_id)
    return volunteer if volunteer.present?
    personen_rolle ||= @personen_rolle.find(personen_rollen_id)
    volunteer_attributes = prepare_attributes(personen_rolle)
    volunteer = Volunteer.new(volunteer_attributes)
    volunteer = personen_rollen_create_update_conversion(volunteer, personen_rolle)
    volunteer.acceptance = handle_volunteer_state(personen_rolle)
    volunteer.save!
    volunteer
  end

  def import_multiple(personen_rollen)
    personen_rollen.map do |key, personen_rolle|
      get_or_create_by_import(key, personen_rolle)
    end
  end

  def import_all(personen_rollen = nil)
    import_multiple(personen_rollen || @personen_rolle.all_volunteers)
  end

  def handle_volunteer_state(personen_rolle)
    return :resigned if personen_rolle[:d_Rollenende]
    return :accepted if personen_rolle[:d_Rollenende].nil?
    :undecided
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
