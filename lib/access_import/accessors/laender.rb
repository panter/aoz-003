class Laender < Accessor
  def hash_all
    make_mappable(:tbl_Länder, :pk_Land, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_Land)
    rec.except(:d_MutDatum, :t_Mutation)
  end
end
