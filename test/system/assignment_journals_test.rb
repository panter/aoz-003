require 'application_system_test_case'

class AssignmentJournalsTest < ApplicationSystemTestCase
  def setup
    @user_volunteer = create :user, role: 'volunteer', email: 'volunteer@example.com'
    @volunteer = @user_volunteer.volunteer = create :volunteer
    @assignment = create :assignment, volunteer: @volunteer
    superadmin = create :user
    @assignment_journal = create :assignment_journal, assignment: @assignment,
      volunteer: @volunteer, author: superadmin, comments: 'author superadmin'
    login_as @user_volunteer
    visit root_url
    click_link 'volunteer@example.com'
    click_link 'Show profile'
  end

  test 'volunteer can create an assignment journal' do
    click_link 'New Assignment journal'
    fill_in 'Which were the most important goals during the last months?', with: 'asdf'
    fill_in 'What could have been achieved during the last months?', with: 'asdf'
    fill_in 'Should the assignment continue? If yes, with which goals?', with: 'asdf'
    fill_in 'Comments', with: 'asdf'
    page.check('assignment_journal_conversation')
    click_button 'Create Assignment journal'
    assert page.has_text? 'Assignment journal was successfully created.'
  end

  test 'volunteer can see only her assignment journals' do
    click_link 'Assignment journal index'
    refute page.has_text? 'author superadmin'
  end

  test 'assignment journal index contains only the journals of one assignment' do
    assignment2 = create :assignment, volunteer: @volunteer
    volunteer_journal = create :assignment_journal, assignment: @assignment,
      author: @user_volunteer, comments: 'assignment1'
    create :assignment_journal, assignment: assignment2, author: @user_volunteer,
      comments: 'assignment2'
    visit assignment_assignment_journal_path(@assignment, volunteer_journal)
    click_link 'Back'
    refute page.has_text? 'assignment2'
  end

  test 'volunteer can create only their assignment journals' do
    assignment = create :assignment
    visit new_assignment_assignment_journal_path(assignment)
    assert page.has_text? 'You are not authorized to perform this action.'
  end
end
