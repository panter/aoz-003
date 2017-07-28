class Plz
  include AccUtils
  attr_reader :records

  def initialize(acdb)
    @acdb = acdb
    @records = hash_all
  end

  def hash_all
    make_mappable(:tbl_PlzOrt, :pk_PlzOrt, true)
  end

  def sanitize_record(rec)
    rec[:fk_Kanton] = rec[:"fk_Kanton Bundesland"]
    rec = parse_int_fields(
      rec,
      [:pk_PlzOrt, :z_PLZ, :fk_Land, :fk_Kanton]
    )
    rec.except(
      :"fk_Kanton Bundesland", :t_Mutation, :d_MutDatum
    )
  end

  def all
    @records
  end

  def find(id)
    @records[id.to_i]
  end
end
