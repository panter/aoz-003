require 'test_helper'

class ArchivedGroupOffersXlsxExportTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user
    login_as @superadmin
  end

  test 'xlsx file is downloadable' do
    10.times { create :group_offer, active: false }
    get archived_group_offers_url(format: :xlsx)
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      response.content_type
  end

  test 'xlsx files has the right columns' do
    create :group_offer, active: false
    wb = get_xls_from_response(archived_group_offers_url(format: :xlsx))

    assert_xls_cols_equal(wb, 1, 0, 'Title', 'Location', 'Availability', 'Target group',
      'Duration', 'Offer state', 'Volunteers', 'Group offer category')

    assert_xls_cols_equal(wb, 2, 0, GroupOffer.archived.first.title)
  end
end
