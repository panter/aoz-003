require 'test_helper'

class CliensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @superadmin = create :user, :with_clients,
      :with_department, role: 'superadmin'
    @social_worker = create :user, :with_clients,
      :with_department, role: 'social_worker'
    @department_manager = create :department_manager
  end
end
