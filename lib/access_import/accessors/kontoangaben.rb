class Kontoangaben < Accessor
  def hash_all
    make_mappable(:tbl_Kontoangaben, :pk_Kontoangabe, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(
      rec, [:pk_Kontoangabe, :fk_Hauptperson, :z_KontoArt, :fk_PlzOrt, :z_ClearingNummer]
    )
    parse_datetime_fields(rec, [:d_MutDatum])
  end

  def where_haupt_person(hp_id)
    @records.select do |_k, kontoangabe|
      kontoangabe[:fk_Hauptperson] == hp_id.to_i
    end
  end
end
