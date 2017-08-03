class HauptPerson < Accessor
  def initialize(acimport, accid = nil)
    @laender = acimport.laender
    @acdb = acimport.acdb
    @plz = acimport.plz
    @sprache_self = acimport.sprache_hauptperson
    if accid
      @record = internal_find(accid)
      return self
    end
    @records = all
    self
  end

  def internal_find(id)
    if @records
      @records[id.to_s]
    else
      person = @acdb[:tbl_Hauptpersonen].find do |hp|
        hp[:pk_Hauptperson] == id.to_s
      end
      @record = sanitize_record(person)
      @record
    end
  end

  def find(id)
    internal_find(id)
  end

  def sanitize_record(rec)
    rec[:t_Geschlecht] = map_gender(rec[:t_Geschlecht])
    rec = parse_date_fields(rec, :d_EintrittCH, :d_Geburtsdatum)
    rec = parse_int_fields(rec, :b_KlientAOZ, :fk_Land, :pk_Hauptperson, :fk_PLZ)
    rec
  end

  def internal_all
    all = @acdb[:tbl_Hauptpersonen].map do |r|
      [
        r[:pk_Hauptperson],
        sanitize_record(r)
      ]
    end.to_h
    @records = all
  end

  def all
    internal_all if @records.blank?
    @records
  end

  def sprachen
    @sprache_self.where_person([:pk_Hauptperson])
  end
end
