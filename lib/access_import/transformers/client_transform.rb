class ClientTransform < Transformer
  def prepare_attributes(personen_rolle)
    haupt_person = @haupt_person.find(personen_rolle[:fk_Hauptperson])
    begleitet, relatives = handle_begleitete(personen_rolle, haupt_person)
    familien_rolle = @familien_rollen.find(begleitet[:fk_FamilienRolle])
    {
      user: @ac_import.import_user,
      nationality: haupt_person[:nationality],
      salutation: haupt_person[:salutation],
      contact_attributes: contact_attributes(haupt_person),
      language_skills_attributes: language_skills_attributes(haupt_person[:sprachen]),
      birth_year: haupt_person[:d_Geburtsdatum],
      entry_date: haupt_person[:d_EintrittCH] && haupt_person[:d_EintrittCH],
      comments: comments(begleitet, personen_rolle, haupt_person),
      relatives_attributes: relatives_attrs(relatives),
      import_attributes: access_import(
        :tbl_PersonenRollen, personen_rolle[:pk_PersonenRolle], personen_rolle: personen_rolle,
        haupt_person: haupt_person, familien_rolle: familien_rolle, begleitet: begleitet,
        relatives: relatives && relatives
      )
    }.merge(handle_acceptance_state(personen_rolle))
  end

  def handle_acceptance_state(personen_rolle)
    if personen_rolle[:d_Rollenende].blank? && personen_rolle[:d_Rollenbeginn].blank?
      { acceptance: :accepted }
    elsif personen_rolle[:d_Rollenende].blank?
      { acceptance: :accepted,
        accepted_at: personen_rolle[:d_Rollenbeginn] }
    else
      { acceptance: :resigned,
        accepted_at: personen_rolle[:d_Rollenbeginn],
        resigned_at: personen_rolle[:d_Rollenende] }
    end
  end

  def get_or_create_by_import(personen_rollen_id, personen_rolle = nil)
    return @entity if get_import_entity(:client, personen_rollen_id).present?
    personen_rolle ||= @personen_rolle.find(personen_rollen_id)
    client = Client.create(prepare_attributes(personen_rolle))
    client.resigned_at = personen_rolle[:d_Rollenende] if client.resigned?
    update_timestamps(client, personen_rolle[:d_Rollenbeginn], personen_rolle[:d_MutDatum])
  end

  def import_all
    @personen_rolle.all_clients.each do |key, personen_rolle|
      get_or_create_by_import(key, personen_rolle)
    end
  end

  def handle_client_acceptance(personen_rolle)
    return 'resigned' if personen_rolle[:d_Rollenende]
    'accepted'
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
