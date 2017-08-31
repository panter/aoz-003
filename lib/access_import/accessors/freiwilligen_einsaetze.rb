class FreiwilligenEinsaetze < Accessor
  def hash_all
    make_mappable(:tbl_FreiwilligenEinsätze, :pk_FreiwilligenEinsatz, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_FreiwilligenEinsatz, :fk_PersonenRolle,
      :fk_FreiwilligenFunktion, :fk_Kostenträger, :fk_EinsatzOrt, :fk_Begleitete,
      :fk_Kurs, :fk_Semester, :fk_Lehrmittel)
    rec = parse_float_fields(rec, :z_FamilienBegleitung, :z_Spesen)
    rec[:fk_FreiwilligenFunktion] = 0 unless rec[:fk_FreiwilligenFunktion]
    rec[:funktion] = FREIWILLIGEN_FUNKTIONEN[rec[:fk_FreiwilligenFunktion]]
    rec[:lehrmittel] = LEHRMITTEL[rec[:fk_Lehrmittel]] if rec[:fk_Lehrmittel]
    rec[:semester] = SEMESTER[rec[:fk_Semester]] if rec[:fk_Semester]
    rec = parse_boolean_fields(rec, :b_Bücher, :b_LP1, :b_LP2, :b_Probezeitbericht)
    parse_datetime_fields(rec, :d_MutDatum, :d_EinsatzVon, :d_EinsatzBis).except(
      :fk_Lehrmittel
    )
  end

  def where_begleitete(begleitet_id)
    all.select do |_key, fw_einsatz|
      fw_einsatz[:fk_Begleitete] == begleitet_id.to_i
    end
  end

  def where_einsatz_ort(einsatz_ort_id)
    all.select do |_key, fw_einsatz|
      fw_einsatz[:fk_EinsatzOrt] == einsatz_ort_id.to_i
    end
  end

  def where_personen_rolle(personen_rolle_id)
    all.select do |_key, fw_einsatz|
      fw_einsatz[:fk_PersonenRolle] == personen_rolle_id.to_i
    end
  end
end
