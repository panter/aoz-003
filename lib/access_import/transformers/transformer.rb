require 'acc_utils'
require 'ostruct'

class Transformer
  include AccUtils

  def initialize(ac_import, *accessors)
    @ac_import = ac_import
    accessors.each do |accessor|
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end

  def personen_rollen_create_update_conversion(model_record, personen_rolle)
    model_record.created_at = personen_rolle[:d_Rollenbeginn]
    model_record.updated_at = personen_rolle[:d_MutDatum]
    model_record
  end

  FREIWILLIGEN_FUNKTION = {
    1 => 'Begleitung',
    2 => 'Kurs',
    3 => 'Animation F',
    4 => 'Kurzeinsatz',
    5 => 'Andere',
    6 => 'Animation A'
  }.freeze


  EINSATZ_ROLLEN = OpenStruct.new(freiwillige: 1, begleitete: 2, animator: 3, teilnehmende: 4)
end
