class Stundenerfassung < Accessor
  def hash_all
    make_mappable(:tbl_Stundenerfassung, :pk_Stundenerfassung, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_Stundenerfassung, :fk_PersonenRolle, :fk_FreiwilligenEinsatz,
                           :fk_Semester, :z_Quartal, :z_Jahr, :z_Einsatzzahl)
    rec = parse_float_fields(rec, :z_Stundenzahl, :z_Spesen)
    parse_datetime_fields(rec, :d_MutDatum)
  end

  def where_personen_rolle(pr_id)
    all.find_all do |_key, stunden_erfassung|
      stunden_erfassung[:fk_PersonenRolle] == pr_id.to_i
    end.to_h
  end
end
