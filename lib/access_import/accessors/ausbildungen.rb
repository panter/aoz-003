class Ausbildungen < Accessor
  def hash_all
    make_mappable(:tbl_Ausbildungen, :pk_Ausbildung, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec,
                           :pk_Ausbildung, :fk_Hauptperson, :fk_AusbildungsTyp, :fk_FreiwilligenEinsatz)
    rec[:ausbildung] = AUSBILDUNGS_TYPEN[rec[:fk_AusbildungsTyp]]
    parse_datetime_fields(rec, :d_MutDatum).except(:fk_AusbildungsTyp)
  end

  def where_haupt_person(hauptperson_id)
    all.select do |_key, ausbildung|
      ausbildung[:fk_Hauptperson] == hauptperson_id.to_i
    end
  end
end
