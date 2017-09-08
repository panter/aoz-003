require 'application_system_test_case'

class CertificatesTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @volunteer = create :volunteer, :with_assignment, state: 'resigned'
    @hour = create :hour, volunteer: @volunteer, assignment: @volunteer.assignments.first, hours: 2,
      minutes: 15
    login_as @user
  end

  test 'only resigned volunteer can get a certificate' do
    active_volunteer = create :volunteer, state: 'active'
    visit volunteer_path(active_volunteer)
    refute page.has_link? 'Create certificate'
    visit volunteer_path(@volunteer)
    assert page.has_link? 'Create certificate'
  end
end
