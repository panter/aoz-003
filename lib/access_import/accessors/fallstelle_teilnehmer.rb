class FallstelleTeilnehmer < Accessor
  def hash_all
    make_mappable(:tbl_FallStelleProTeilnehmer, :pk_FallStelleProTeilnehmer, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_FallStelleProTeilnehmer, :fk_PersonenRolle, :fk_Fallstelle,
                           :fk_Kontaktperson)
    parse_datetime_fields(rec, :d_MutDatum)
  end
end
