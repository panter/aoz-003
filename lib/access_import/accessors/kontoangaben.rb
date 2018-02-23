class Kontoangaben < Accessor
  def hash_all
    make_mappable(:tbl_Kontoangaben, :pk_Kontoangabe, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_Kontoangabe, :fk_Hauptperson, :z_KontoArt, :fk_PlzOrt,
      :z_ClearingNummer)
    rec[:city] = "#{ort[:t_Ort]} #{ort[:t_PLZ]}" if ort(rec[:fk_PlzOrt]).present?
    parse_datetime_fields(rec, :d_MutDatum)
  end

  def ort(plz_id = nil)
    @ort ||= @plz.find(plz_id)
  end

  def where_haupt_person(hp_id)
    related = all.find_all do |_key, kontoangabe|
      kontoangabe[:fk_Hauptperson] == hp_id.to_i
    end
    return if related.blank?
    return related.first.last if related.size == 1
    related.sort_by { |_, angabe| angabe[:d_MutDatum] }.last.last
  end
end
