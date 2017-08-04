class SpracheProHauptperson < Accessor
  def hash_all
    make_mappable(:tbl_SpracheProHauptperson, :pk_SpracheProPerson, true)
  end

  LANGUAGE_LEVELS = [nil, 'basic', 'good', 'fluent', 'native_speaker', nil].freeze

  def sanitize_record(rec)
    rec = parse_int_fields(rec, *level_keys, :fk_Hauptperson, :fk_Sprache, :pk_SpracheProPerson)
    rec = add_kentniss_levels(rec)
    rec[:language] = @sprachen.find(rec[:fk_Sprache])
    rec.except(
      :d_MutDatum, :t_Mutation, :fk_KenntnisstufeLe, :fk_KenntnisstufeSc, :fk_KenntnisstufeSp,
      :fk_KenntnisstufeVe
    )
  end

  def add_kentniss_levels(record)
    kentnisse = record.slice(*level_keys).compact.map do |k, v|
      [k.to_s[3..-1].to_sym, LANGUAGE_LEVELS[v]]
    end.to_h
    record.merge(kentnisse).except(*level_keys)
  end

  def level_keys
    ['Le', 'Sc', 'Sp', 'Ve'].map { |k| "fk_Kenntnisstufe#{k}".to_sym }
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
end
