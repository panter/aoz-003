class Laender < Accessor
  def hash_all
    make_mappable(:tbl_Länder, :pk_Land, true)
  end

  def laender_map
    @laender_map ||= CSV.read('lib/access_import/accessors/laender_map_alpha2.csv',
      headers: true, converters: :numeric, header_converters: :symbol).map do |row|
        [row[:pk_land], row[:alpha2]]
      end.to_h
  end

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_Land)
    rec[:alpha2] = laender_map[rec[:pk_Land]]
    rec
  end
end
