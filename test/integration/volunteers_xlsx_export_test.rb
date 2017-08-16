require 'test_helper'

class VolunteersXlsxExportTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user, role: 'superadmin'
    10.times { create :volunteer }
  end

  test 'xlsx file is downloadable' do
    login_as @superadmin
    get volunteers_url(format: :xlsx)
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      response.content_type
  end
end
