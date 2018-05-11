class SpracheProHauptperson < Accessor
  def hash_all
    make_mappable(:tbl_SpracheProHauptperson, :pk_SpracheProPerson, true)
  end

  LANGUAGE_LEVELS = {
    1 => 'basic',
    2 => 'good',
    3 => 'fluent',
    6 => 'basic',
    7 => 'native_speaker'
  }.freeze

  def sanitize_record(rec)
    rec = parse_int_fields(rec, *level_keys, :fk_Hauptperson, :fk_Sprache, :pk_SpracheProPerson)
    # rec = add_kentniss_levels(rec)
    # rec[:language] = @sprachen.find(rec[:fk_Sprache])
    levels = rec.values_at(:fk_KenntnisstufeLe, :fk_KenntnisstufeSc, :fk_KenntnisstufeSp, :fk_KenntnisstufeVe)
    level = levels.max == 6 ? (levels - [6]).max : levels.max
    rec[:level] = LANGUAGE_LEVELS[level]
    rec[:language] = I18n.t('language_names').find { |_, v| v[:pk_sprache] == rec[:fk_Sprache] }&.first
    rec.except(
      :d_MutDatum, :t_Mutation
    )
  end

  def add_kentniss_levels(record)
    kentnisse = record.slice(*level_keys).compact.map do |key, level|
      [key.to_s[3..-1].to_sym, LANGUAGE_LEVELS[level]]
    end.to_h
    record.merge(kentnisse).except(*level_keys)
  end

  def level_keys
    ['Le', 'Sc', 'Sp', 'Ve'].map { |key| "fk_Kenntnisstufe#{key}".to_sym }
  end

  def where_person(person_id)
    persons_sprachen = all.select do |_key, sprache_hauptperson|
      sprache_hauptperson[:fk_Hauptperson].to_s == person_id.to_s
    end
    persons_sprachen.map { |_key, sprache_hauptperson| down_hkeys(sprache_hauptperson) }
  end
end
