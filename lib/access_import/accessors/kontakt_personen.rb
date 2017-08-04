class KontaktPersonen < Accessor
  def hash_all
    make_mappable(:tbl_KontaktPersonen, :pk_Kontaktperson, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_Kontaktperson, :fk_FallStelle)
    rec[:email] = email(rec[:h_Email])
    parse_datetime_fields(rec, :d_MutDatum).except(:h_Email)
  end
end
