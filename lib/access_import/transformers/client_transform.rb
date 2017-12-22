class ClientTransform < Transformer
  def prepare_attributes(personen_rolle)
    haupt_person = @haupt_person.find(personen_rolle[:fk_Hauptperson])
    begleitet, relatives = handle_begleitete(personen_rolle, haupt_person)
    familien_rolle = @familien_rollen.find(begleitet[:fk_FamilienRolle])
    {
      salutation: haupt_person[:salutation],
      comments: comments(begleitet, personen_rolle, haupt_person),
      birth_year: haupt_person[:d_Geburtsdatum],
      entry_date: haupt_person[:d_EintrittCH] && haupt_person[:d_EintrittCH],
      nationality: haupt_person[:nationality],
      language_skills_attributes: language_skills_attributes(haupt_person[:sprachen]),
      contact_attributes: contact_attributes(haupt_person),
      relatives_attributes: relatives_attrs(relatives),
      user: @ac_import.import_user,
      import_attributes: access_import(
        :tbl_PersonenRollen, personen_rolle[:pk_PersonenRolle], personen_rolle: personen_rolle,
        haupt_person: haupt_person, familien_rolle: familien_rolle, begleitet: begleitet,
        relatives: relatives && relatives
      )
    }
  end

  def get_or_create_by_import(personen_rollen_id, personen_rolle = nil)
    client = Import.get_imported(Client, personen_rollen_id)
    return client if client.present?
    personen_rolle ||= @personen_rolle.find(personen_rollen_id)
    client_attributes = prepare_attributes(personen_rolle)
    client = Client.new(client_attributes)
    client = personen_rollen_create_update_conversion(client, personen_rolle)
    client.state = handle_client_state(personen_rolle)
    client.save!
    client
  end

  def import_all
    @personen_rolle.all_clients.each do |key, personen_rolle|
      get_or_create_by_import(key, personen_rolle)
    end
  end

  def handle_client_state(personen_rolle)
    if personen_rolle[:d_Rollenende]
      Client::FINISHED
    elsif personen_rolle[:d_Rollenende].nil?
      Client::ACTIVE
    else
      Client::REGISTERED
    end
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
    if begleitet.size == 1
      return [begleitet.first[1], begleitete.except(begleitet.first[0])]
    end
    begleitet = begleitete.select do |_key, beg|
      beg[:t_Vorname] == haupt_person[:t_Vorname]
    end
    if begleitet.size == 1
      return [begleitet.first[1], begleitete.except(begleitet.first[0])]
    end
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
