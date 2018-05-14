class ClientTransform < Transformer
  def prepare_attributes(personen_rolle, haupt_person)
    begleitet, relatives = handle_begleitete(personen_rolle, haupt_person)
    familien_rolle = @familien_rollen.find(begleitet[:fk_FamilienRolle])
    {
      user: @ac_import.import_user,
      nationality: haupt_person[:nationality],
      salutation: haupt_person[:salutation] || 'family',
      birth_year: haupt_person[:d_Geburtsdatum],
      profession: haupt_person[:t_Beruf]
      entry_date: haupt_person[:d_EintrittCH] && Date.parse(haupt_person[:d_EintrittCH]).to_date.to_s,
      comments: comments(begleitet, personen_rolle, haupt_person),
      relatives_attributes: relatives_attrs(relatives),
      accepted_at: personen_rolle[:d_Rollenbeginn],
      resigned_at: personen_rolle[:d_Rollenende],
      cost_unit: personen_rolle[:cost_unit]
    }.merge(contact_attributes(haupt_person))
      .merge(language_skills_attributes(haupt_person[:sprachen]))
      .merge(import_attributes(:tbl_PersonenRollen, personen_rolle[:pk_PersonenRolle],
        personen_rolle: personen_rolle, haupt_person: haupt_person, familien_rolle: familien_rolle,
        begleitet: begleitet, relatives: relatives && relatives))
  end

  def get_or_create_by_import(personen_rollen_id, personen_rolle = nil)
    client = get_import_entity(:client, personen_rollen_id)
    return client if client.present?
    personen_rolle ||= @personen_rolle.find(personen_rollen_id)
    return if personen_rolle[:d_Rollenende].present? && personen_rolle[:d_Rollenende] < Time.zone.now
    haupt_person = @haupt_person.find(personen_rolle[:fk_Hauptperson]) || {}
    client = Client.new(prepare_attributes(personen_rolle, haupt_person))
    if haupt_person == {} # handle access db inconsistencies
      client.contact.assign_attributes(primary_email: generate_bogus_email, street: 'xxx',
        postal_code: '8000', city: 'Zürich')
      client.assign_attributes(acceptance: :resigned, resigned_at: personen_rolle[:d_Rollenende])
    end
    if !client.save && client.errors.messages[:'contact.primary_email']&.include?('ist bereits vergeben')
      clients_with_same_email = Client.joins(:contact)
        .where('contacts.primary_email = ?', client.contact.primary_email)
      if clients_with_same_email.maximum(:updated_at) < personen_rolle[:d_MutDatum]
        clients_with_same_email.map { |cl| cl.contact.update(primary_email: generate_bogus_email) }
      else
        client.contact.primary_email = generate_bogus_email
      end
      client.save!
    end
    update_timestamps(client, personen_rolle[:d_Rollenbeginn], personen_rolle[:d_MutDatum])
  end

  def default_all
    @personen_rolle.all_clients
  end

  def comments(begleitet, personen_rolle, haupt_person)
    comments = ''
    comments += "#{begleitet[:m_Bemerkung]}\n\n" if begleitet[:m_Bemerkung]
    comments += "#{personen_rolle[:m_Bemerkungen]}\n\n" if personen_rolle[:m_Bemerkungen]
    comments += "#{haupt_person[:m_Bemerkungen]}\n\n" if haupt_person[:m_Bemerkungen]
    comments
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

  def relatives_attrs(relatives)
    relatives.map do |_key, relative|
      [(Time.now.to_f * 1000).to_i, {
        first_name: relative[:t_Vorname],
        last_name: relative[:t_Name], relation: relative[:relation],
        birth_year: relative[:z_Jahrgang] && Date.parse("#{relative[:z_Jahrgang]}-01-01")
      }]
    end.to_h
  end
end
