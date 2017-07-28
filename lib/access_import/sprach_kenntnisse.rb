class SprachKenntnisse
  include AccUtils
  attr_reader :records

  def initialize(acdb)
    @acdb = acdb
    @records = hash_all
  end

  def hash_all
    make_mappable(:tbl_Sprachkenntnisse, :pk_Sprachkenntnis, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, [:pk_Sprachkenntnis])
    parse_datetime_fields(rec, [:d_MutDatum])
  end

  def all
    @records
  end

  def find(id)
    @records[id.to_i]
  end
end
