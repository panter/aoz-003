class EinsatzOrte < Accessor
  def hash_all
    make_mappable(:tbl_EinsatzOrte, :pk_EinsatzOrt, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_EinsatzOrt, :fk_PlzOrt)
    if rec[:fk_PlzOrt].positive?
      rec[:city], rec[:postal_code] = @plz.find(rec[:fk_PlzOrt]).values_at(:t_Ort, :t_PLZ)
    end
    parse_datetime_fields(rec, :d_MutDatum).except(:fk_AusbildungsTyp)
  end

  def where_haupt_person(hauptperson_id)
    @records.select do |_k, ausbildung|
      ausbildung[:fk_Hauptperson] == hauptperson_id.to_i
    end
  end
end
