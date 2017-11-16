require 'test_helper'

class VolunteersXlsxExportTest < ActionDispatch::IntegrationTest
  test 'xlsx file is downloadable' do
    superadmin = create :user
    10.times { create :volunteer }
    login_as superadmin
    get volunteers_url(format: :xlsx)
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      response.content_type
  end
end
