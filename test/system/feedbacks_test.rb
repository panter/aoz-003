require 'application_system_test_case'

class FeedbacksTest < ApplicationSystemTestCase
  def setup
    @user_volunteer = create :user, role: 'volunteer', email: 'volunteer@example.com'
    @volunteer = @user_volunteer.volunteer = create :volunteer
    @assignment = create :assignment, volunteer: @volunteer
    superadmin = create :user
    @feedback = create :feedback, feedbackable: @assignment,
      volunteer: @volunteer, author: superadmin, comments: 'author superadmin'
    login_as @volunteer.user
  end

  test 'volunteer can create an feedback' do
    visit root_url
    click_link 'volunteer@example.com'
    click_link 'Show profile'
    click_link 'New Feedback'
    fill_in 'Which were the most important goals during the last months?', with: 'asdf'
    fill_in 'What could have been achieved during the last months?', with: 'asdf'
    fill_in 'Should the assignment continue? If yes, with which goals?', with: 'asdf'
    fill_in 'Comments', with: 'asdf'
    page.check('feedback_conversation')
    click_button 'Create Feedback'
    assert page.has_text? 'Feedback was successfully created.'
  end

  test 'volunteer can see only her feedbacks' do
    visit root_url
    click_link 'volunteer@example.com'
    click_link 'Show profile'
    click_link 'Feedback index'
    refute page.has_text? 'author superadmin'
  end

  test 'feedback index contains only the journals of one assignment' do
    assignment2 = create :assignment, volunteer: @volunteer
    volunteer_journal = create :feedback, feedbackable: @assignment,
      author: @user_volunteer, comments: 'assignment1'
    create :feedback, feedbackable: assignment2, author: @user_volunteer,
      comments: 'assignment2'
    visit assignment_feedback_path(@assignment, volunteer_journal)
    click_link 'Back'
    refute page.has_text? 'assignment2'
  end

  test 'volunteer can create only their feedbacks' do
    assignment = create :assignment, volunteer: create(:volunteer)
    visit new_assignment_feedback_path(assignment)
    assert page.has_text? 'You are not authorized to perform this action.'
  end
end
