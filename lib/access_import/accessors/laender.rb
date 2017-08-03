class Laender < Accessor
  def hash_all
    make_mappable(:tbl_Länder, :pk_Land, true)
  end

  INCONSISTENT_LANDER_MAP = {
    'Bosnien': 'BA',
    'Fürstentum Liechtenstein': 'LI',
    'Togo': 'TG',
    'Tunesien': 'TN',
    'Elfenbeinküste': 'CI',
    'Aserbeidschdan': 'AZ',
    'Libanon': 'LB',
    'Philippinen': 'PH',
    'Holland': 'NL',
    'Mongolei': 'MN',
    'Kongo': 'CD',
    'Singapur': 'SG',
    'Oesterreich': 'AT',
    'Lybien': 'LY',
    'Kuba': 'CU',
    'Ungarn': 'HU',
    'Kanada': 'CA',
    'Saudi Arabien': 'SA',
    'Chile': 'CL',
    'Algerien': 'DZ',
    'Mazedonien': 'MK',
    'Slowakei': 'SK',
    'Venezuela': 'VE',
    'Tansania': 'TZ',
    'Republik Montenegro': 'ME',
    'Palästina': 'PS',
    'Spanien': 'ES',
    'Gambia': 'GM',
    'Südafrika': 'ZA',
    'Ghana': 'GH',
    'Taiwan': 'TW',
    'Sudan': 'SD',
    'Guatemala': 'GT',
    'Serbien': 'RS',
    'Serbien-Montenegro': 'RS',
    'Aethiopien': 'ET',
    'Pakistan': 'PK',
    'China': 'CN',
    'Malay': 'MY',
    'Tibet': 'TI',
    'Kosovo': 'KO',
    'Guinea': 'GN'
  }.freeze

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_Land)
    rec.except(:d_MutDatum, :t_Mutation)
    if INCONSISTENT_LANDER_MAP[rec[:t_Land].to_sym]
      return ISO3166::Country[INCONSISTENT_LANDER_MAP[rec[:t_Land].to_sym]].un_locode
    end
    alpha_2_search = alpha_2_search(rec[:t_LandKurzform])
    return alpha_2_search[0].un_locode if alpha_2_search.size == 1 && alpha_2_search[0]
    alpha_3_search = alpha_3_search(rec[:t_LandKurzform])
    return alpha_3_search[0].un_locode if alpha_3_search.size == 1 && alpha_3_search[0]
  end

  def alpha_2_search(kurzform)
    ISO3166::Country.all.select { |c| c.alpha2 == kurzform.upcase } || []
  end

  def alpha_3_search(kurzform)
    ISO3166::Country.all.select { |c| c.alpha3 == kurzform.upcase } || []
  end
end
