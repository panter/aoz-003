require 'tasks_test_helper'

class AccessImportsTest < ActiveSupport::TestCase
  test 'active_volunteers' do
    active_xls = parse_volunteers_xls_header(extract_xlsx('ListeAktiveFreiwillige'))
    found_active_volunteers = find_all_from_xls(active_xls, Volunteer.joins(:contact))
    found_active_volunteers.each_value do |result|
      assert_basic_values(result[:row], result[:found])
    end

    active_volunteer_ids = found_active_volunteers.map { |_, hash| hash[:found].id }
    Volunteer.where.not(id: active_volunteer_ids).each do |volunteer|
      assert volunteer.resigned?, "Volunteer(id: #{volunteer.id}, full_name: "\
        "#{volunteer.contact.full_name}) not resigned, but it should have been"
    end
  end

  test 'active_clients' do
    active_xls = parse_clients_xls_header(extract_xlsx('ListeAktiveBegleitete'))
    found_active_clients = find_all_from_xls(active_xls, Client.joins(:contact))
    found_active_clients.each_value do |result|
      assert_basic_values(result[:row], result[:found])
    end

    active_client_ids = found_active_clients.map { |_, hash| hash[:found].id }
    Client.where.not(id: active_client_ids).each do |client|
      assert client.resigned?, "Client(id: #{client.id}, full_name: "\
        "#{client.contact.full_name}) not resigned, but it should have been"
    end
  end

  def assert_basic_values(row, found)
    assert_equal row[:first_name].to_s, found.contact.first_name.to_s
    assert_equal row[:last_name].to_s, found.contact.last_name.to_s
    assert_equal row[:city].to_s, found.contact.city.to_s
    assert_equal row[:street].to_s, found.contact.street.to_s
    assert_equal row[:extended].to_s, found.contact.extended.to_s
    assert_equal row[:secondary_phone].to_s, found.contact.secondary_phone&.strip.to_s
    assert_nil found.resigned_at
    assert_equal anrede_to_salutation(row[:anrede]).to_s, found.salutation.to_s,
      "Salutation on #{found.id} is #{found.salutation} where it should be #{row[:anrede]}"
    if found.is_a?(Client)
      assert_equal row[:entry_date]&.to_date.to_s, found.entry_date.to_s.strip
    else
      assert_equal row[:waive] == 'Ja', found.waive,
        "#{row[:waive]} and here is #{found.waive}, volunteer_id: #{found.id}"
    end
  end

  def find_all_from_xls(xls, query)
    xls.each_with_index.map do |row, index|
      [index, { found: find_from_row(row, query), row: row }]
    end.to_h
  end

  def parse_clients_xls_header(xls)
    xls.parse(
      anrede: /Anrede/, last_name: /Nachname/, first_name: /Vorname/,
      street: /Adresszeile\ 1/, extended: /Adresszeile\ 2/, postal_code: /PLZ/,
      city: /Ort/, primary_phone: /Telefon/, secondary_phone: /Mobile/, email: /Email/,
      birth_year: /Geburtsdatum/, gender: /Geschlecht/, nationality: /Nationalität/,
      profession: /Beruf/, entry_date: /Eintritt\ CH/, period_start: /Beginn/, period_end: /Ende/,
      persons_in_family: /Anzahl\ Personen/
    )
  end

  def parse_volunteers_xls_header(xls)
    xls.parse(
      anrede: /Anrede/, last_name: /Nachname/, first_name: /Vorname/,
      street: /Adresszeile\ 1/, extended: /Adresszeile\ 2/, postal_code: /PLZ/,
      city: /Ort/, primary_phone: /Telefon/, secondary_phone: /Mobile/, email: /Email/,
      birth_year: /Geburtsdatum/, gender: /Geschlecht/, nationality: /Nationalität/,
      profession: /Beruf/, entry_date: /Eintritt\ CH/, period_start: /Beginn/, period_end: /Ende/,
      intro_course: /Einführungskurs/, waive: /Spesenverzicht/, state: /Aktueller\ Status/
    )
  end

  def find_from_row(hash, query)
    found, query = narrow_query(query, 'contacts.first_name = ?', hash[:first_name])
    return query if found || (!found && !query)

    found, query = narrow_query(query, 'contacts.last_name = ?', hash[:last_name])
    return query if found || (!found && !query)

    found, query = narrow_query(query, 'contacts.postal_code = ?', hash[:postal_code])
    return query if found || (!found && !query)

    found, query = narrow_query(query, 'contacts.city = ?', hash[:city])
    return query if found || (!found && !query)

    found, query = narrow_query(query, 'contacts.street = ?', hash[:street])
    return query if found || (!found && !query)

    found, query = narrow_query(query, 'contacts.extended = ?', hash[:extended])
    return query if found || (!found && !query)

    found, query = narrow_query(query, 'birth_year = ?', hash[:birth_year])
    return [false, query] unless found
    query
  end

  def anrede_to_salutation(anrede)
    case anrede
    when 'Herr'
      'mr'
    when 'Frau'
      'mrs'
    when '<neutral>'
      'mr'
    end
  end

  def narrow_query(query, sql_condition, value)
    query = query.where(sql_condition, value)
    return [false, false] if query.count.zero?
    return [false, query] if query.count > 1
    [true, query.first]
  end
end
