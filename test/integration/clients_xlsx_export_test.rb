require 'test_helper'

class ClientsXlsxExportTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user, role: 'superadmin'
    10.times { create :client }
  end

  test 'xlsx file is downloadable' do
    login_as @superadmin
    get clients_url(format: :xlsx)
    assert_equal('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      response.content_type)
  end
end
