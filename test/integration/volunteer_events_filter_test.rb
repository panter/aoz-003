require 'test_helper'

class VolunteerEventsFilterTest < ActionDispatch::IntegrationTest
  # def setup
  #   @superadmin = create :user
  #   @volunteer_intro_visited = create :volunteer, intro_course: true
  #   @volunteer_intro_not_visited = create :volunteer, intro_course: false
  #   login_as @superadmin
  # end

  # TODO: Flappy test
  # test 'Volunteer intro course visited filter returns correct volunteers' do
  #   get volunteers_path(q: { intro_course_eq: 'true' })
  #   assert response.body.include? @volunteer_intro_visited.full_name
  #   refute response.body.include? @volunteer_intro_not_visited.full_name
  # end

  # TODO: Flappy test
  # test 'Volunteer intro course not visited filter returns correct volunteers' do
  #   get volunteers_path(q: { intro_course_eq: 'false' })
  #   assert response.body.include? @volunteer_intro_not_visited.full_name
  #   refute response.body.include? @volunteer_intro_visited.full_name
  # end
end
