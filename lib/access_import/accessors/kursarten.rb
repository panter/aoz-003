class Kursarten < Accessor
  def hash_all
    make_mappable(:tbl_Kursarten, :pk_Kursart, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_Kursart)
    rec = parse_boolean_fields(rec, :b_Status)
    parse_datetime_fields(rec, :d_MutDatum)
  end
end
