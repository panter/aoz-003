class Fallstellen
  def hash_all
    make_mappable(:tbl_FallStellen, :pk_FallStelle, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(
      rec, [:pk_FallStelle, :fk_PLZ]
    )
    rec[:email] = email(rec[:h_Email])
    parse_datetime_fields(rec, [:d_MutDatum])
  end
end
