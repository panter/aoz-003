require 'acc_utils'
require 'ostruct'

# Transformer creates Rails records from Access records
#
class Transformer
  include AccUtils

  def initialize(ac_import, *accessors)
    @ac_import = ac_import
    accessors.each do |accessor|
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end

  def get_import_entity(class_name, access_record_id)
    Import.with_deleted.get_imported(class_name.to_s.singularize.classify, access_record_id)
  end

  def import_time_email
    "importiert#{Time.zone.now.to_f}@example.com"
  end

  def update_timestamps(record, date, updated_date = nil)
    return record if date.blank?
    record.update(created_at: date, updated_at: updated_date || date)
    record
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
