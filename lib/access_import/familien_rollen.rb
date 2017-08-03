class FamilienRollen
  include AccUtils
  attr_reader :records

  def initialize(acdb)
    @acdb = acdb
    @records = hash_all
  end

  def hash_all
    make_mappable(:tbl_FamilienRollen, :pk_FamilienRolle, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_FamilienRolle)
    rec[:d_MutDatum] = rec[:d_MutDatum].to_datetime
    rec
  end

  def all
    @records
  end

  def find(id)
    @records[id.to_i]
  end
end
