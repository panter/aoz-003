require 'test_helper'

class GroupOffersXlsxExportTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user
    10.times { create :group_offer }
  end

  test 'xlsx file is downloadable' do
    login_as @superadmin
    get group_offers_url(format: :xlsx)
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      response.content_type
  end
end
