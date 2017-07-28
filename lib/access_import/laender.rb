class Laender
  include AccUtils
  attr_reader :records

  def initialize(acdb)
    @acdb = acdb
    @records = hash_all
  end

  def hash_all
    make_mappable(:tbl_Länder, :pk_Land, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, [:pk_Land])
    rec.except(:d_MutDatum, :t_Mutation)
  end

  def all
    @records
  end

  def find(id)
    @records[id.to_i]
  end
end
