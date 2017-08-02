class FreiwilligenEinsaetze < Accessor
  def hash_all
    make_mappable(:tbl_FreiwilligenEinsätze, :pk_FreiwilligenEinsatz, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec,
      [:pk_FreiwilligenEinsatz, :fk_PersonenRolle, :fk_FreiwilligenFunktion, :fk_Kostenträger,
       :fk_EinsatzOrt, :fk_Begleitete, :fk_Kurs, :fk_Semester, :fk_Lehrmittel])
    rec = parse_float_fields(rec, [:z_FamilienBegleitung, :z_Spesen])
    rec[:funktion] = FREIWILLIGEN_FUNKTIONEN[rec[:fk_FreiwilligenFunktion]] if rec[:fk_FreiwilligenFunktion]
    rec[:lehrmittel] = LEHRMITTEL[rec[:fk_Lehrmittel]] if rec[:fk_Lehrmittel]
    rec[:semester] = SEMESTER[rec[:fk_Semester]] if rec[:fk_Semester]
    parse_datetime_fields(rec, [:d_MutDatum, :d_EinsatzVon, :d_EinsatzBis]).except(
      :fk_FreiwilligenFunktion, :fk_Lehrmittel
    )
  end

  def where_begleitete(beg_id)
    @records.select do |_k, fw_einsatz|
      fw_einsatz[:fk_Begleitete] == beg_id.to_i
    end
  end

  def where_einsatz_ort(einsatz_ort_id)
    @records.select do |_k, fw_einsatz|
      fw_einsatz[:fk_EinsatzOrt] == einsatz_ort_id.to_i
    end
  end

  def where_einsatz_ort(kurs_id)
    @records.select do |_k, fw_einsatz|
      fw_einsatz[:fk_Kurs] == kurs_id.to_i
    end
  end

  def where_personen_rolle(pr_id)
    @records.select do |_k, fw_einsatz|
      fw_einsatz[:fk_PersonenRolle] == pr_id.to_i
    end
  end
end
