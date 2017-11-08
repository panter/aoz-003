require 'test_helper'

class ClientsXlsxExportTest < ActionDispatch::IntegrationTest
  include ApplicationHelper
  def setup
    @superadmin = create :user, role: 'superadmin'
    login_as @superadmin
  end

  test 'xlsx file is downloadable' do
    10.times { create :client }
    get clients_url(format: :xlsx)
    assert_equal('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      response.content_type)
  end

  test 'xlsx files columns and cells are correct' do
    client = create :client, entry_date: 'Feb. 2014', birth_year: 30.years.ago,
      education: 'educati', created_at: 2.days.ago, nationality: 'IT'

    get clients_url(format: :xlsx)
    excel_file = Tempfile.new
    excel_file.write(response.body)
    excel_file.close
    wb = Roo::Spreadsheet.open(excel_file.path, extension: 'xlsx')

    assert_equal 'id',               wb.cell(1, 1)
    assert_equal 'Salutation',       wb.cell(1, 2)
    assert_equal 'Name',             wb.cell(1, 3)
    assert_equal 'First name',       wb.cell(1, 4)
    assert_equal 'Street',           wb.cell(1, 5)
    assert_equal 'Extended address', wb.cell(1, 6)
    assert_equal 'Zip',              wb.cell(1, 7)
    assert_equal 'City',             wb.cell(1, 8)
    assert_equal 'Primary phone',    wb.cell(1, 9)
    assert_equal 'Secondary phone',  wb.cell(1, 10)
    assert_equal 'Primary email',    wb.cell(1, 11)
    assert_equal 'Birth year',       wb.cell(1, 12)
    assert_equal 'Nationality',      wb.cell(1, 13)
    assert_equal 'Education',        wb.cell(1, 14)
    assert_equal 'Entry date',       wb.cell(1, 15)
    assert_equal 'State',            wb.cell(1, 16)
    assert_equal 'Created at',       wb.cell(1, 17)
    assert_equal 'Updated at',       wb.cell(1, 18)

    assert_equal client.id.to_s,                             wb.cell(2, 1).to_s
    assert_equal I18n.t("salutation.#{client.salutation}"),  wb.cell(2, 2)
    assert_equal client.contact.last_name,                   wb.cell(2, 3)
    assert_equal client.contact.first_name,                  wb.cell(2, 4)
    assert_equal client.contact.street,                      wb.cell(2, 5)
    assert_equal client.contact.extended,                    wb.cell(2, 6)
    assert_equal client.contact.postal_code,                 wb.cell(2, 7)
    assert_equal client.contact.city,                        wb.cell(2, 8)
    assert_equal client.contact.primary_phone,               wb.cell(2, 9)
    assert_equal client.contact.secondary_phone,             wb.cell(2, 10)
    assert_equal client.contact.primary_email,               wb.cell(2, 11)
    assert_equal client.birth_year&.year,                    wb.cell(2, 12)
    assert_equal nationality_name(client.nationality),       wb.cell(2, 13)
    assert_equal client.education,                           wb.cell(2, 14)
    assert_equal client.entry_date,                          wb.cell(2, 15)
    assert_equal I18n.t("state.#{client.state}"),            wb.cell(2, 16)
    assert_equal client.created_at.to_date,                  wb.cell(2, 17).to_date
    assert_equal client.updated_at.to_date,                  wb.cell(2, 18).to_date
  end

  test 'clients xls export is not paginated' do
    30.times { create :client }
    get clients_url(format: :xlsx)
    excel_file = Tempfile.new
    excel_file.write(response.body)
    excel_file.close
    wb = Roo::Spreadsheet.open(excel_file.path, extension: 'xlsx')
    assert_equal Client.count + 1, wb.last_row
  end
end
