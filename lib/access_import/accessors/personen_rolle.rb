class PersonenRolle < Accessor
  def hash_all
    make_mappable(:tbl_Personenrollen, :pk_PersonenRolle, true)
  end

  def sanitize_record(rec)
    rec = parse_datetime_fields(rec, :d_MutDatum, :d_Rollenbeginn, :d_Rollenende)
    rec = parse_int_fields(rec, :b_EinführungsKurs, :b_Interesse, :b_SpesenVerzicht,
      :fk_Hauptperson, :fk_Kostenträger, :pk_PersonenRolle, :z_AnzErw, :z_AnzKind,
      :z_Familienverband, :z_Rolle)
    rec[:rolle] = ACCESS_TO_OWN_ROLES_MAP[rec[:z_Rolle]]
    rec
  end

  ACCESS_TO_OWN_ROLES_MAP = {
    1 => 'Volunteer',
    2 => 'Client',
    3 => 'Animator',
    4 => 'Participant'
  }.freeze

  def all_volunteers
    all.select do |_id, personen_rolle|
      personen_rolle[:z_Rolle] == ACCESS_ROLES.volunteer
    end
  end

  def all_clients
    all.select do |_id, personen_rolle|
      personen_rolle[:z_Rolle] == ACCESS_ROLES.client
    end
  end

  def all_animators
    all.select do |_id, personen_rolle|
      personen_rolle[:z_Rolle] == ACCESS_ROLES.animator
    end
  end

  def all_participants
    all.select do |_id, personen_rolle|
      personen_rolle[:z_Rolle] == ACCESS_ROLES.participant
    end
  end
end
