class Journale < Accessor
  def hash_all
    make_mappable(:tbl_Journal, :pk_Journal, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_Journal, :fk_Hauptperson, :fk_JournalKategorie,
                           :fk_FreiwilligenEinsatz)
    rec[:kategorie] = JOURNAL_KATEGORIEN[rec[:fk_JournalKategorie]]
    parse_datetime_fields(rec, :d_MutDatum, :d_ErfDatum)
  end

  def where_haupt_person(hp_id)
    all.select do |_key, journal|
      journal[:fk_Hauptperson] == hp_id.to_i
    end
  end
end
