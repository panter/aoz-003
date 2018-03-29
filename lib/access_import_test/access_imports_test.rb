require_relative '../tasks_test_helper'

# rubocop:disable all
class AccessImportsTest < ActiveSupport::TestCase
  test 'active_volunteers' do
    active_xls = parse_volunteers_xls_header(extract_xlsx('ListeAktiveFreiwillige'))
    found_active_volunteers = find_all_from_xls(active_xls, Volunteer.joins(:contact))
    found_active_volunteers.each do |result|
      assert_basic_values(result[:row], result[:found])
    end

    puts "Verified #{found_active_volunteers.size} volunteer records."

    active_volunteer_ids = found_active_volunteers.map { |hash| hash[:found].id }
    Volunteer.where.not(id: active_volunteer_ids).each do |volunteer|
      assert volunteer.resigned?, "Volunteer(id: #{volunteer.id}, full_name: "\
        "#{volunteer.contact.full_name}) not resigned, but it should have been"
    end
  end

  test 'active_clients' do
    active_xls = parse_clients_xls_header(extract_xlsx('ListeAktiveBegleitete'))
    found_active_clients = find_all_from_xls(active_xls, Client.joins(:contact))
    found_active_clients.each do |result|
      assert_basic_values(result[:row], result[:found])
    end

    puts "Verified #{found_active_clients.size} client records."

    active_client_ids = found_active_clients.map { |hash| hash[:found].id }
    Client.where.not(id: active_client_ids).each do |client|
      assert client.resigned?, "Client(id: #{client.id}, full_name: "\
        "#{client.contact.full_name}) not resigned, but it should have been"
    end
  end

  def assert_basic_values(row, found)
    columns = [:first_name, :last_name, :city, :street, :extended, :secondary_phone]

    expected = row.slice(*columns)
      .transform_values { |v| v.to_s.strip }

    actual = found.contact.slice(*columns)
      .symbolize_keys
      .transform_values { |v| v.to_s.strip }

    assert_equal expected, actual

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
    xls.map do |row|
      found = find_from_row(row, query)
      { found: found, row: row } if found
    end.compact
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
    result = query.joins(:contact).find_by(
      contacts: {
        first_name: hash[:first_name].presence,
        last_name: hash[:last_name].presence,
        postal_code: hash[:postal_code].presence,
        city: hash[:city].presence,
        street: hash[:street].presence,
        extended: hash[:extended].presence
      }
    )

    if result
      result
    else
      puts "\nCan't find record for #{hash.inspect}"
      nil
    end
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
