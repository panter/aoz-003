class PersonenRolle
  include AccUtils
  attr_reader :records

  def initialize(acdb)
    @acdb = acdb
    @records = hash_map_all
  end

  def hash_map_all
    make_mappable(:tbl_Personenrollen, :pk_PersonenRolle, true)
  end

  def sanitize_record(rec)
    rec = parse_datetime_fields(rec, [:d_MutDatum, :d_Rollenbeginn, :d_Rollenende])
    rec = parse_int_fields(rec, [
                             :b_EinführungsKurs, :b_Interesse, :b_SpesenVerzicht, :fk_Hauptperson,
                             :fk_Kostenträger, :pk_PersonenRolle, :z_AnzErw, :z_AnzKind,
                             :z_Familienverband, :z_Rolle
                           ])
    rec[:rolle] = map_rolle(rec[:z_Rolle])
    rec
  end

  def map_rolle(z_rolle)
    return 'Volunteer' if z_rolle == 1
    return 'Client' if z_rolle == 2
    return 'Animator' if z_rolle == 3
    return 'Participant' if z_rolle == 4
    nil
  end

  def all_volunteers
    @records.select do |_id, val|
      val[:z_Rolle] == 1
    end
  end

  def all_clients
    @records.select do |_id, val|
      val[:z_Rolle] == 2
    end
  end

  def all_animators
    @records.select do |_id, val|
      val[:z_Rolle] == 3
    end
  end

  def all_participants
    @records.select do |_id, val|
      val[:z_Rolle] == 4
    end
  end

  def all
    @records
  end

  def find(id)
    @records[id.to_i]
  end
end
