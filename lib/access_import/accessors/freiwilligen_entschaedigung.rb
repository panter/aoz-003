class FreiwilligenEntschaedigung < Accessor
  def hash_all
    make_mappable(:tbl_FreiwilligenEntschädigung, :pk_FreiwilligenEntschädigung, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_FreiwilligenEntschädigung, :fk_PersonenRolle, :fk_Semester,
                           :z_Semesterjahr, :z_Jahr, :z_Einsätze, :z_Stunden, :z_Betrag, :z_Spesen, :z_KST, :z_AOZKonto)
    rec = parse_float_fields(rec, :z_Total)
    rec[:semester] = rec[:fk_Semester]
    parse_datetime_fields(rec, :d_MutDatum, :d_Datum).except(:fk_Semester)
  end

  def where_personen_rolle(pr_id)
    all.select do |_key, fw_einsatz|
      fw_einsatz[:fk_PersonenRolle] == pr_id.to_i
    end
  end
end
