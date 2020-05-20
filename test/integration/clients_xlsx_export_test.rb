require 'test_helper'

class ClientsXlsxExportTest < ActionDispatch::IntegrationTest
  include ApplicationHelper
  def setup
    @superadmin = create :user, role: 'superadmin'
    login_as @superadmin
  end

  test 'xlsx files columns and cells are correct' do
    client = create :client, entry_date: 'Feb. 2014', birth_year: 30.years.ago.to_date,
      education: 'educati', created_at: 2.days.ago, nationality: 'IT'
    client.update(created_at: 2.days.ago.to_date, updated_at: 2.days.ago.to_date)

    Client.with_deleted.where.not(id: client.id).map(&:really_destroy!)
    wb = get_xls_from_response(clients_url(format: :xlsx))
    assert_xls_cols_equal(wb, 1, 0, 'id', 'Anrede', 'Nachname', 'Vorname', 'Strasse',
                          'Adresszusatz', 'PLZ', 'Ort', 'Telefonnummer', 'Telefonnummer 2', 'Mailadresse',
                          'Geburtsdatum', 'Nationalität', 'Beruf oder Ausbildung im Herkunftsland',
                          'Einreisedatum', 'Prozess', 'Fallführende Stelle', 'Sprachkenntnisse', 'Inhalte der Begleitung', 'Erstellt am', 'Aktualisiert am')

    assert_equal client.id.to_s, wb.cell(2, 1).to_s
    assert_xls_cols_equal(wb, 2, 1,
                          I18n.t("salutation.#{client.salutation}"),
                          client.contact.last_name,
                          client.contact.first_name,
                          client.contact.street,
                          client.contact.extended,
                          client.contact.postal_code,
                          client.contact.city,
                          client.contact.primary_phone,
                          client.contact.secondary_phone,
                          client.contact.primary_email,
                          Axlsx::DateTimeConverter.date_to_serial(client.birth_year),
                          nationality_name(client.nationality),
                          client.education,
                          client.entry_date,
                          I18n.t(".acceptance.#{client.acceptance}"),
                          client.involved_authority,
                          '',
                          client.goals)
    assert_equal 2.days.ago.to_date, wb.cell(2, 20).to_date
    assert_equal 2.days.ago.to_date, wb.cell(2, 21).to_date
  end

  test 'clients xls export is not paginated' do
    30.times { create :client }
    wb = get_xls_from_response(clients_url(format: :xlsx))
    assert_equal Client.count + 1, wb.last_row
  end
end
