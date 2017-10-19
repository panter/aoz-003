require 'test_helper'

class ArchivedGroupOffersXlsxExportTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user
    10.times { create :group_offer, active: false }
    login_as @superadmin
    get archived_group_offers_url(format: :xlsx)
  end

  test 'xlsx file is downloadable' do
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      response.content_type
  end

  test 'xlsx files has the right columns' do
    excel_file = Tempfile.new
    excel_file.write(response.body)
    excel_file.close
    wb = Roo::Spreadsheet.open(excel_file.path, extension: 'xlsx')

    assert_equal wb.cell(1, 1), 'Title'
    assert_equal wb.cell(2, 1), GroupOffer.archived.last.title
    assert_equal wb.cell(1, 2), 'Location'
    assert_equal wb.cell(1, 3), 'Availability'
    assert_equal wb.cell(1, 4), 'Target group'
    assert_equal wb.cell(1, 5), 'Duration'
    assert_equal wb.cell(1, 6), 'Offer state'
    assert_equal wb.cell(1, 7), 'Volunteers'
    assert_equal wb.cell(1, 8), 'Group offer category'
  end
end
