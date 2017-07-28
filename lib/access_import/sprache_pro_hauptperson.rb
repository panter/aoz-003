class SpracheProHauptperson
  include AccUtils
  attr_reader :records

  def initialize(acdb, sprachen, sprach_kenntnisse)
    @acdb = acdb
    @sprachen = sprachen
    @sprach_kenntnisse = sprach_kenntnisse
    @records = hash_all
  end

  def hash_all
    make_mappable(:tbl_SpracheProHauptperson, :pk_SpracheProPerson, true)
  end

  def sanitize_record(rec)
    level_keys = ['Le', 'Sc', 'Sp', 'Ve'].map { |k| "fk_Kenntnisstufe#{k}".to_sym }
    rec = parse_int_fields(rec, level_keys.push(:fk_Hauptperson, :fk_Sprache, :pk_SpracheProPerson))
    level_keys.each do |level|
      rec[level.to_s[3..-1].to_sym] = map_kentniss_level(rec[level])
    end
    rec[:language] = @sprachen.find(rec[:fk_Sprache])
    rec.except(
      :d_MutDatum, :t_Mutation, :fk_KenntnisstufeLe, :fk_KenntnisstufeSc, :fk_KenntnisstufeSp,
      :fk_KenntnisstufeVe
    )
  end

  def map_kentniss_level(kentniss_id)
    [nil, 'basic', 'good', 'fluent', 'native_speaker', nil][kentniss_id]
  end

  def all
    @records
  end

  def where_person(person_id)
    languages = @records.select do |key|
      key.to_s == person_id.to_s
    end
    languages.map { |s| down_hkeys(s[1]) }
  end

  def find(id)
    @records[id.to_i]
  end
end
