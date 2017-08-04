class KostenTraeger < Accessor
  def hash_all
    make_mappable(:tbl_Kostenträger, :pk_Kostenträger, true)
  end

  def sanitize_record(rec)
    parse_int_fields(rec, :pk_Kostenträger).except(
      :d_MutDatum, :t_Mutation
    )
  end
end
