require 'application_system_test_case'

class FeedbacksTest < ApplicationSystemTestCase
  def setup
    @user_volunteer = create :user_volunteer, email: 'volunteer@example.com'
    @volunteer = create :volunteer, user: @user_volunteer
    @assignment = create :assignment, volunteer: @volunteer
    @superadmin = create :user
    @feedback = create :feedback, feedbackable: @assignment,
      volunteer: @volunteer, author: @superadmin, comments: 'author superadmin'
    login_as @user_volunteer
    @other_volunteer = create :volunteer, user: create(:user_volunteer)
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

  test 'assignment feedback index contains only the feedbacks of one assignment' do
    assignment2 = create :assignment, volunteer: @volunteer
    create :feedback, volunteer: @volunteer, feedbackable: assignment2,
      author: @superadmin, comments: 'assignment_number_2'
    volunteer_feedback = create :feedback, volunteer: @volunteer, feedbackable: @assignment,
      author: @user_volunteer, comments: 'assignment_number_1'
    visit assignment_feedback_path(@assignment, volunteer_feedback)
    click_link 'Back'
    refute page.has_text? 'assignment_number_2'
  end

  test 'group offer feedbacks index contains only the feedbacks related to that group offer' do
    group_offer = create :group_offer, necessary_volunteers: 2, title: 'some_group_offer',
      volunteers: [@volunteer, @other_volunteer]
    some_feedback = create :feedback, feedbackable: group_offer, author: @user_volunteer,
      volunteer: @volunteer, comments: 'some_feedback'
    some_superadmin_feedback = create :feedback, feedbackable: group_offer, author: @superadmin,
      volunteer: @volunteer, comments: 'some_superadmin_feedback'
    other_group_offer = create :group_offer, necessary_volunteers: 2, title: 'some_other_group_offer',
      volunteers: [@volunteer, @other_volunteer]
    other_feedback = create :feedback, volunteer: @volunteer, feedbackable: other_group_offer,
      author: @user_volunteer, comments: 'other_feedback'
    login_as @user_volunteer
    visit group_offer_feedbacks_path(group_offer)
    assert page.has_text? 'some_feedback'
    refute page.has_text? 'some_superadmin_feedback'
    refute page.has_text? 'other_feedback'
    login_as @superadmin
    visit group_offer_feedbacks_path(group_offer)
  end

  test 'volunteer can create only their feedbacks' do
    assignment = create :assignment, volunteer: create(:volunteer)
    visit new_assignment_feedback_path(assignment)
    assert page.has_text? 'You are not authorized to perform this action.'
  end
end
