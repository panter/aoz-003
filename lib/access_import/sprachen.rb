class Sprachen
  include AccUtils
  attr_reader :records

  def initialize(acdb)
    @acdb = acdb
    @records = hash_all
  end

  def hash_all
    make_mappable(:tbl_Sprachen, :pk_Sprache, true)
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_Sprache)
    {
      lang: language(rec[:t_Sprache]),
      sprache: rec[:t_Sprache]
    }
  end

  def language(sprache)
    sprache = 'Tigrinja' if sprache == 'Tigrinia'
    I18nData.languages(:de).select { |_k, v| v == sprache }.keys.first
  end

  def all
    @records
  end

  def find(id)
    @records[id.to_i]
  end
end
