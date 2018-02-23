class HauptPerson < Accessor
  def hash_all
    make_mappable(:tbl_Hauptpersonen, :pk_Hauptperson, true)
  end

  def sanitize_record(rec)
    rec[:t_Geschlecht] = map_gender(rec[:t_Geschlecht])
    rec = parse_date_fields(rec, :d_EintrittCH, :d_Geburtsdatum)
    rec = parse_int_fields(rec, :b_KlientAOZ, :fk_Land, :pk_Hauptperson, :fk_PLZ)
    rec[:salutation] = salutation(rec[:t_Anrede], rec[:t_Geschlecht])
    rec[:city], rec[:postal_code] = handle_plz(rec[:fk_PLZ])
    rec[:email] = rec[:h_Email] ? email(rec[:h_Email]) : email(nil)
    rec[:nationality] = rec[:fk_Land] && @laender.find(rec[:fk_Land])
    rec[:sprachen] = @sprache_pro_hauptperson.where_person(rec[:pk_Hauptperson])
    rec
  end

  def handle_plz(fk_plz)
    if fk_plz&.positive?
      @plz.find(fk_plz).values_at(:t_Ort, :t_PLZ)
    else
      ['', '']
    end
  end
end
