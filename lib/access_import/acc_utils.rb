module AccUtils
  def make_mappable(table_name, primary_key, sanitize = false)
    @acdb[table_name].map do |r|
      [
        r[primary_key].to_i,
        sanitize ? sanitize_record(r) : r
      ]
    end.to_h
  end

  # normalize hash keys from access db
  # they can be with uppercase and special chars
  #
  def down_hkeys(row)
    row.transform_keys { |key| key.to_s.underscore.to_sym }
  end

  def parse_int_fields(record, *keys)
    record.merge(record.slice(*keys).compact.transform_values(&:to_i))
  end

  def parse_datetime_fields(record, *keys)
    record.merge(record.slice(*keys).compact.transform_values(&:to_time))
  end

  def parse_float_fields(record, *keys)
    record.merge(record.slice(*keys).compact.transform_values(&:to_f))
  end

  def parse_date_fields(record, *keys)
    record.merge(record.slice(*keys).compact.transform_values(&:to_date))
  end

  def parse_boolean_fields(record, *keys)
    record.merge(
      parse_int_fields(record, *keys).slice(*keys).compact.transform_values do |val|
        val == 1
      end
    )
  end

  def salutation(anrede, gender = nil)
    return 'mrs' if anrede == 'Frau'
    return 'mr' if anrede == 'Herr'
    return 'mrs' if gender == 'female'
    return 'mr' if gender == 'male'
    nil
  end

  def email(h_email)
    return "unknown_email_#{Time.now.to_i}@example.com" if h_email.nil?
    h_email.sub(/^\#mailto:/, '').sub(/\#$/, '')
  end

  def map_gender(value)
    return nil unless value
    return 'female' if value == 'W'
    return 'male' if value == 'M'
  end

  def contact_attributes(haupt_person)
    { contact_attributes: {
      first_name:      haupt_person[:t_Vorname] || 'unbekannt',
      last_name:       haupt_person[:t_Nachname] || 'unbekannt',
      street:          haupt_person[:t_Adresszeile1] || 'unbekannt',
      extended:        haupt_person[:t_Adresszeile2],
      city:            haupt_person[:city] || 'unbekannt',
      postal_code:     haupt_person[:postal_code] || '0000',
      primary_email:   haupt_person[:email],
      primary_phone:   haupt_person[:t_Telefon1] || '000 000 00 00',
      secondary_phone: haupt_person[:t_Telefon2]
    } }
  end

  def import_attributes(access_name, access_id, related_records)
    { import_attributes: access_import(access_name, access_id, related_records) }
  end

  def access_import(access_name, access_id, related_records)
    {
      access_id: access_id,
      base_origin_entity: access_name.to_s,
      store: related_records
    }
  end

  def language_skills_attributes(sprachen)
    { language_skills_attributes: map_sprachen_to_language_skills(sprachen) }
  end

  def map_sprachen_to_language_skills(sprachen)
    return {} if sprachen.blank?
    sprachen.map do |sprache|
      [(Time.now.to_f * 1000).to_i,
       {
         language: sprache[:language][:lang],
         level: sprache[:kenntnisstufe_ve].presence || 'basic'
       }]
    end.to_h
  end

  def now
    Time.zone.now
  end

  def birth_year(geburtsdatum, jahrgang)
    return geburtsdatum if geburtsdatum
    Date.parse(jahrgang + '-06-01') if jahrgang
  end
end
