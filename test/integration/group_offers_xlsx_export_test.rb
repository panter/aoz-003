require 'test_helper'

class GroupOffersXlsxExportTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user
    login_as @superadmin
  end

  test 'xlsx file is downloadable' do
    10.times { create :group_offer }
    get group_offers_url(format: :xlsx)
    assert_equal Mime[:xlsx], response.content_type
  end

  test 'xlsx files has the right columns' do
    create :group_offer
    wb = get_xls_from_response(group_offers_url(format: :xlsx))
    assert_xls_cols_equal(wb, 1, 0, 'Title', 'Location', 'Verantwortliche/r', 'Availability',
      'Target group', 'Duration', 'Offer state', 'Volunteers', 'Group offer category')
    assert_xls_cols_equal(wb, 2, 0, GroupOffer.first.title)
  end
end
