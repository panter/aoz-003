require 'application_system_test_case'

class HoursTest < ApplicationSystemTestCase
  def setup
    user_volunteer = create :user, role: 'volunteer', email: 'volunteer1@example.com'
    volunteer = user_volunteer.volunteer = create :volunteer
    client = create :client
    assignment = create :assignment, volunteer: volunteer, client: client
    superadmin = create :user
    create :assignment_journal, assignment: assignment, volunteer: volunteer,
      author: superadmin, comments: 'author superadmin'
    login_as user_volunteer
    visit root_url
    click_link 'volunteer1@example.com'
    click_link 'Show profile'
  end

  test 'volunteer can create an assignment journal' do
    click_link 'New Assignment journal'
    fill_in 'Goals', with: 'asdf'
    fill_in 'Achievements', with: 'asdf'
    fill_in 'Future', with: 'asdf'
    fill_in 'Comments', with: 'asdf'
    page.check('assignment_journal_conversation')
    click_button 'Create Assignment journal'
    assert page.has_text? 'Assignment journal was successfully created.'
  end

  test 'volunteer can see only her assignment journals' do
    click_link 'Assignment journal index'
    refute page.has_text? 'author superadmin'
  end
end
