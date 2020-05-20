class ClientTransform < Transformer
  def prepare_attributes(personen_rolle, haupt_person, begleitet, relatives)
    familien_rolle = @familien_rollen.find(begleitet[:fk_FamilienRolle])
    verfahrens_histories = @verfahrens_history.where_haupt_person(haupt_person[:pk_Hauptperson]).values
    {
      user: @ac_import.import_user,
      nationality: haupt_person[:nationality],
      salutation: haupt_person[:salutation] || 'family',
      birth_year: haupt_person[:d_Geburtsdatum],
      entry_date: haupt_person[:d_EintrittCH] && Date.parse(haupt_person[:d_EintrittCH]).to_date.to_s,
      comments: comments(begleitet, personen_rolle, haupt_person),
      accepted_at: personen_rolle[:d_Rollenbeginn],
      resigned_at: personen_rolle[:d_Rollenende],
      cost_unit: personen_rolle[:cost_unit],
      permit: verfahrens_histories.any? ? verfahrens_histories.first[:permit] : nil
    }.merge(contact_attributes(haupt_person))
      .merge(import_attributes(:tbl_PersonenRollen, personen_rolle[:pk_PersonenRolle],
                               personen_rolle: personen_rolle, haupt_person: haupt_person, familien_rolle: familien_rolle,
                               begleitet: begleitet, verfahrens_history: verfahrens_histories && verfahrens_histories,
                               relatives: relatives && relatives))
  end

  def get_or_create_by_import(personen_rollen_id, personen_rolle = nil)
    client = get_import_entity(:client, personen_rollen_id)
    return client if client.present?

    personen_rolle ||= @personen_rolle.find(personen_rollen_id)
    return if personen_rolle[:d_Rollenende].present? && personen_rolle[:d_Rollenende] < Time.zone.now

    haupt_person = @haupt_person.find(personen_rolle[:fk_Hauptperson]) || {}
    begleitet, relatives = handle_begleitete(personen_rolle, haupt_person)
    client = Client.new(prepare_attributes(personen_rolle, haupt_person, begleitet, relatives))
    client.relatives = init_relatives(relatives)
    handle_missing_haupt_person(client, personen_rolle) if haupt_person == {}
    handle_language_skills(client, haupt_person)
    handle_missing_email(client, personen_rolle) unless client.save
    update_timestamps(client, personen_rolle[:d_Rollenbeginn], personen_rolle[:d_MutDatum])
  end

  def default_all
    @personen_rolle.all_clients
  end

  def comments(begleitet, personen_rolle, haupt_person)
    [
      begleitet[:m_Bemerkung], personen_rolle[:m_Bemerkungen], haupt_person[:m_Bemerkungen]
    ].compact.join(";\n\n")
  end

  def handle_missing_haupt_person(client, personen_rolle)
    client.contact.assign_attributes(street: 'xxx',
      postal_code: '8000', city: 'Zürich')
    client.assign_attributes(acceptance: :resigned, resigned_at: personen_rolle[:d_Rollenende])
  end

  def handle_language_skills(client, haupt_person)
    if haupt_person[:sprachen]&.any?
      client.language_skills = haupt_person[:sprachen].map do |sprache|
        LanguageSkill.new(language: sprache[:language], level: sprache[:level])
      end
    end
    unless client.language_skills.map(&:language).include?('DE')
      client.language_skills = [LanguageSkill.new(language: 'DE', level: 'basic')]
    end
  end

  def handle_missing_email(client, personen_rolle)
    return unless client.errors.messages[:'contact.primary_email']&.include?('ist bereits vergeben')

    client.contact.primary_email = nil
    client.save!
  end

  def handle_begleitete(personen_rolle, haupt_person)
    begleitete = @begleitete.where_personen_rolle(personen_rolle[:pk_PersonenRolle])
    return [begleitete.first[1], []] if begleitete.size == 1

    begleitet = begleitete.select do |_key, beg|
      beg[:fk_FamilienRolle] == 2 # Hauptperson
    end
    return [begleitet.first[1], begleitete.except(begleitet.first[0])] if begleitet.size == 1

    begleitet = begleitete.select do |_key, beg|
      beg[:t_Vorname] == haupt_person[:t_Vorname]
    end
    return [begleitet.first[1], begleitete.except(begleitet.first[0])] if begleitet.size == 1

    begleitet = begleitete.select do |_key, beg|
      haupt_person[:t_Vorname].include? beg[:t_Vorname]
    end
    # either last match worked or nothing worked, just take first in order to
    # have a at least somewhat consistent thing
    [begleitet.first[1], begleitete.except(begleitet.first[0])]
  end

  def init_relatives(relatives)
    relatives.map do |_, relative|
      Relative.new(first_name: relative[:t_Vorname], last_name: relative[:t_Name],
        relation: relative[:relation], birth_year: relative[:birth_year])
    end
  end
end
