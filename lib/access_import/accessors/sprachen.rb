class Sprachen < Accessor
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
    I18n.t('language_names').find { |_key, language| language == sprache }.first
  end
end
