class VerfahrensHistory < Accessor
  def hash_all
    make_mappable(:tbl_VerfahrensHistory, :pk_VerfahrensHistory, true)
  end

  MAP_PERMIT = {
    1 => :N, 2 => :F, 3 => :PF, 4 => :B, 5 => :C, 6 => :CH, 8 => :B
  }.freeze

  def sanitize_record(rec)
    rec = parse_int_fields(rec, :pk_VerfahrensHistory, :fk_Hauptperson, :fk_VerfahrensStatus,
                           :fk_FamilienRolle)
    rec[:permit] = MAP_PERMIT[rec[:fk_VerfahrensStatus]] if rec[:fk_VerfahrensStatus]&.positive?
    parse_datetime_fields(rec, :d_MutDatum, :d_PerDatum)
  end

  def where_haupt_person(hp_id)
    all.find_all do |_key, verfahrens_history|
      verfahrens_history[:fk_Hauptperson] == hp_id.to_i
    end.to_h
  end
end
