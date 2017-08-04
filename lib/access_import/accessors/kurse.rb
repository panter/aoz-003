class Kurse < Accessor
  def hash_all
    make_mappable(:tbl_Kurse, :pk_Kurs, true)
  end

  def sanitize_record(rec)
    parse_int_fields(rec, :pk_Kurs, :fk_Kursart)
  end
end
