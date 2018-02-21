require 'tasks_test_helper'

class AccessImportsTest < ActiveSupport::TestCase
  test 'tryit out' do
    active_xls = extract_xlsx('ListeAktiveFreiwillige')
    found_active_volunteers = find_all_volunteers_in_xls(active_xls)
    # all_xls = extract_xlsx('ListeAllerFreiwilligen')
    # found_all_volunteers = find_all_volunteers_in_xls(all_xls)
    binding.pry
  end

  def find_volunteer_from_row(hash)
    found, query = narrow_query(Volunteer.joins(:contact), 'contacts.first_name = ?', hash[:first_name])
    return query if found || (!found && !query)

    found, query = narrow_query(query, 'contacts.last_name = ?', hash[:last_name])
    return query if found || (!found && !query)

    found, query = narrow_query(query, 'contacts.postal_code = ?', hash[:postal_code])
    return query if found || (!found && !query)

    found, query = narrow_query(query, 'contacts.city = ?', hash[:city])
    return query if found || (!found && !query)

    found, query = narrow_query(query, 'profession = ?', hash[:profession])
    return query if found || (!found && !query)


    found, query = narrow_query(query, 'waive = ?', hash[:waive] == 'Ja')
    return query if found || (!found && !query)
    # found, query = narrow_query(query, 'contacts.primary_email = ?', row[9])
    # return query if found || (!found && !query)

    # found, query = narrow_query(query, 'contacts.primary_phone = ?', row[8])

    found, query = narrow_query(query, 'birth_year = ?', hash[:birth_year])
    return [false, query] unless found
    query
  end

  def find_all_volunteers_in_xls(xls)
    xls.parse(
      anrede: /Anrede/, last_name: /Nachname/, first_name: /Vorname/,
      street: /Adresszeile\ 1/, extended: /Adresszeile\ 2/, postal_code: /PLZ/,
      city: /Ort/, primary_phone: /Telefon/, secondary_phone: /Mobile/, email: /Email/,
      birth_year: /Geburtsdatum/, gender: /Geschlecht/, nationality: /Nationalität/,
      profession: /Beruf/, entry_date: /Eintritt\ CH/, period_start: /Beginn/, period_end: /Ende/,
      intro_course: /Einführungskurs/, waive: /Spesenverzicht/, state: /Aktueller\ Status/
    ).each_with_index.map do |row, index|
      [index, { found: find_volunteer_from_row(row), row: row }]
    end.to_h
  end

  def narrow_query(query, sql_condition, value)
    query = query.where(sql_condition, value)
    return [false, false] if query.count.zero?
    return [false, query] if query.count > 1
    [true, query.first]
  end
end
