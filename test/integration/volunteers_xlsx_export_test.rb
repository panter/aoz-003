require 'test_helper'

class VolunteersXlsxExportTest < ActionDispatch::IntegrationTest
  test 'xlsx file is downloadable' do
    superadmin = create :user
    10.times { create :volunteer }
    login_as superadmin
    get volunteers_url(format: :xlsx)
    assert_equal Mime[:xlsx], response.content_type
  end
  test 'xlsx files has the right columns' do
    superadmin = create :user
    volunteer = create :volunteer
    login_as superadmin
    wb = get_xls_from_response(volunteers_url(format: :xlsx))
    assert_xls_cols_equal(
      wb, 1, 0,
      'id',
      'Anrede',
      'Nachname',
      'Vorname',
      'Strasse',
      'Adresszusatz',
      'PLZ',
      'Ort',
      'Telefonnummer',
      'Telefonnummer 2',
      'Mailadresse',
      'Jahrgang',
      'Nationalität',
      'Beruf',
      'Prozess',
      'Anmeldedatum',
      'Aktualisiert am',
      'Anzahl begleitungen',
      'Spesenverzicht',
      'Einführungskurs besucht'
    )
    
  end
end
