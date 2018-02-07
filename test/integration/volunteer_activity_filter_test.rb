require 'test_helper'

class VolunteerActivityFilterTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user
    @volunteer_undecided = create :volunteer, acceptance: 'undecided'
    @volunteer_invited = create :volunteer_with_user, acceptance: 'invited'
    @volunteer_active = create :volunteer_with_user
    create :assignment_active, volunteer: @volunteer_active
    @volunteer_resigned = create :volunteer_with_user, acceptance: 'resigned'
    create :assignment_active, volunteer: @volunteer_resigned
    @volunteer_inactive = create :volunteer_with_user
    create :assignment_inactive, volunteer: @volunteer_inactive
    login_as @superadmin
  end

  test 'Volunteer state active filter returns active volunteer' do
    get volunteers_path(q: { active: 'true' })
    assert response.body.include? @volunteer_active.full_name
    refute response.body.include? @volunteer_inactive.full_name
    refute response.body.include? @volunteer_resigned.full_name
    refute response.body.include? @volunteer_undecided.full_name # needs to be fixed
    refute response.body.include? @volunteer_invited.full_name # needs to be fixed
  end

  test 'Volunteer state inactive filter returns inactive volunteer' do
    get volunteers_path(q: { active: 'false' })
    refute response.body.include? @volunteer_active.full_name
    assert response.body.include? @volunteer_inactive.full_name
    refute response.body.include? @volunteer_resigned.full_name
    refute response.body.include? @volunteer_undecided.full_name # needs to be fixed
    refute response.body.include? @volunteer_invited.full_name # needs to be fixed
  end
end

