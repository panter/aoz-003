module AccUtils
  def make_mappable(table_name, primary_key, sanitize = false)
    @acdb[table_name].map do |r|
      [
        r[primary_key].to_i,
        sanitize ? sanitize_record(r) : r
      ]
    end.to_h
  end

  def down_hkeys(row)
    row.transform_keys { |key| key.to_s.underscore.to_sym }
  end

  def parse_int_fields(record, *keys)
    record.merge(record.slice(*keys).compact.transform_values(&:to_i))
  end

  def parse_datetime_fields(record, *keys)
    record.merge(record.slice(*keys).compact.transform_values(&:to_datetime))
  end

  def parse_date_fields(record, *keys)
    record.merge(record.slice(*keys).compact.transform_values(&:to_date))
  end

  def salutation(anrede)
    return 'mrs' if anrede == 'Frau'
    return 'mr' if anrede == 'Herr'
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
end
