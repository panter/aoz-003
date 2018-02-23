class Rollen < Accessor
  def hash_all
    make_mappable(:tbl_Rollen, :pk_Rolle, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_Rolle)
    parse_datetime_fields(rec, :d_MutDatum)
  end
end
