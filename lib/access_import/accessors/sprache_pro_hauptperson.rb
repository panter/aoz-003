class SpracheProHauptperson < Accessor
  def hash_all
    make_mappable(:tbl_SpracheProHauptperson, :pk_SpracheProPerson, true)
  end

  LANGUAGE_ID_MAPPING = {
    1 => :DE, 2 => :EN, 3 => :FR, 4 => :IT, 5 => :GS, 6 => :SQ, 7 => :TR, 8 => :KU, 9 => :RU,
    10 => :HY, 11 => :AR, 12 => :ES, 13 => :SO, 14 => :BO, 15 => :SH, 16 => :BS, 17 => :PS,
    18 => :FA, 19 => :UR, 20 => :LN, 21 => :KG, 22 => :HI, 23 => :TI, 24 => :AM, 25 => :CM,
    26 => :TA, 28 => :DA, 30 => :RR, 31 => :BG, 32 => :RM, 33 => :CS, 34 => :NL, 35 => :MM,
    36 => :PT, 37 => :HE, 38 => :SI, 39 => :AZ, 40 => :BC, 41 => :HU, 42 => :AT, 43 => :JA,
    44 => :MK, 45 => :RO, 47 => :ZH, 48 => :MN, 49 => :BL, 50 => :PL, 52 => :BN, 53 => :NE,
    54 => :DR, 55 => :TZ, 56 => :LB, 57 => :SV, 58 => :EL, 59 => :KA, 60 => :KO, 61 => :ID,
    62 => :CE, 63 => :SK, 64 => :SW, 65 => :AH, 66 => :SR, 67 => :FI, 68 => :TH, 69 => :KD,
    70 => :RA, 71 => :MA, 72 => :NO, 73 => :AF, 74 => :HR, 75 => :ML, 76 => :FF
  }.freeze

  LANGUAGE_LEVELS = {
    1 => 'basic',
    2 => 'good',
    3 => 'fluent',
    6 => 'basic',
    7 => 'native_speaker'
  }.freeze

  def sanitize_record(rec)
    rec = parse_int_fields(rec, *level_keys, :fk_Hauptperson, :fk_Sprache, :pk_SpracheProPerson)
    levels = rec.values_at(:fk_KenntnisstufeLe, :fk_KenntnisstufeSc, :fk_KenntnisstufeSp, :fk_KenntnisstufeVe)
    level = levels.max == 6 ? (levels - [6]).max : levels.max
    rec[:level] = LANGUAGE_LEVELS[level] || 'basic'
    rec[:language] = LANGUAGE_ID_MAPPING[rec[:fk_Sprache]]
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
