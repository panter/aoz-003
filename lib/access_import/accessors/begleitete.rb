class Begleitete < Accessor
  def hash_all
    make_mappable(:tbl_Begleitete, :pk_Begleitete, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :fk_FamilienRolle, :fk_PersonenRolle, :pk_Begleitete)
    rec = parse_datetime_fields(rec, :d_MutDatum)
    rec[:gender] = map_gender(rec[:t_Geschlecht])
    rec[:relation] = map_familien_rolle(rec)
    rec
  end

  def where_personen_rolle(pr_id)
    @records.select do |_key, pr|
      pr[:fk_PersonenRolle] == pr_id.to_i
    end
  end

  # :wife, :husband, :mother, :father, :daughter, :son, :sister, :brother, :aunt, :uncle
  # 1: <keine>, 2: 'Hauptperson', 3: 'Ehepartner/in', 4: 'Kind', 5: 'Geschwister', 6: 'Eltern'
  #
  def map_familien_rolle(record)
    return nil if [nil, 1, 2].include? record[:fk_FamilienRolle]
    return handle_female(record) if record[:gender] == 'female'
    handle_male(record) if record[:gender] == 'male'
  end

  def handle_female(record)
    return 'mother' if record[:fk_FamilienRolle] == 6
    return 'sister' if record[:fk_FamilienRolle] == 5
    return 'wife' if record[:fk_FamilienRolle] == 3
    'daughter' if record[:fk_FamilienRolle] == 4
  end

  def handle_male(record)
    return 'father' if record[:fk_FamilienRolle] == 6
    return 'brother' if record[:fk_FamilienRolle] == 5
    return 'husband' if record[:fk_FamilienRolle] == 3
    'son' if record[:fk_FamilienRolle] == 4
  end
end
