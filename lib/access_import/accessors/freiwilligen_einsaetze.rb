class FreiwilligenEinsaetze < Accessor
  def hash_all
    make_mappable(:tbl_FreiwilligenEinsätze, :pk_FreiwilligenEinsatz, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_FreiwilligenEinsatz, :fk_PersonenRolle, :fk_FreiwilligenFunktion,
                           :fk_Kostenträger, :fk_EinsatzOrt, :fk_Begleitete, :fk_Kurs, :fk_Semester, :fk_Lehrmittel, :z_FamilienBegleitung)
    rec = parse_float_fields(rec, :z_Spesen)
    rec[:cost_unit] = cost_unit(rec[:fk_Kostenträger])
    rec[:fk_FreiwilligenFunktion] = 0 unless rec[:fk_FreiwilligenFunktion]
    rec[:funktion] = freiwilligen_funktion(rec[:fk_FreiwilligenFunktion]).bezeichnung
    rec[:lehrmittel] = LEHRMITTEL[rec[:fk_Lehrmittel]] if rec[:fk_Lehrmittel]
    rec[:semester] = SEMESTER[rec[:fk_Semester]] if rec[:fk_Semester]
    rec = parse_boolean_fields(rec, :b_Probezeitbericht, :b_LP1, :b_LP2, :b_Bücher)
    parse_datetime_fields(rec, :d_EinsatzVon, :d_EinsatzBis, :d_Probezeit, :d_Hausbesuch,
                          :d_ErstUnterricht, :d_Standortgespräch, :d_MutDatum)
      .except(:fk_Lehrmittel, :fk_Semester)
  end

  def where_begleitung
    all.select do |_key, fw_einsatz|
      fw_einsatz[:fk_FreiwilligenFunktion] == FREIWILLIGEN_FUNKTION_BY_NAME.begleitung.id
    end
  end

  def where_kurs
    all.select do |_key, fw_einsatz|
      fw_einsatz[:fk_FreiwilligenFunktion] == FREIWILLIGEN_FUNKTION_BY_NAME.kurs.id
    end
  end

  def where_animation_f
    all.select do |_key, fw_einsatz|
      fw_einsatz[:fk_FreiwilligenFunktion] == FREIWILLIGEN_FUNKTION_BY_NAME.animation_f.id
    end
  end

  def where_kurzeinsatz
    all.select do |_key, fw_einsatz|
      fw_einsatz[:fk_FreiwilligenFunktion] == FREIWILLIGEN_FUNKTION_BY_NAME.kurzeinsatz.id
    end
  end

  def where_andere
    all.select do |_key, fw_einsatz|
      fw_einsatz[:fk_FreiwilligenFunktion] == FREIWILLIGEN_FUNKTION_BY_NAME.andere.id
    end
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

  def where_kurs(kurs_id)
    all.select do |_key, fw_einsatz|
      fw_einsatz[:fk_Kurs] == kurs_id.to_i
    end
  end
end
