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
    @group_offer = create :group_offer, necessary_volunteers: 2, title: 'some_group_offer',
    volunteers: [@volunteer, @other_volunteer]
    create :feedback, feedbackable: @group_offer, author: @user_volunteer,
    volunteer: @volunteer, comments: 'some_group_offer_feedback'
    create :feedback, feedbackable: @group_offer, author: @superadmin, volunteer: @volunteer,
      comments: 'some_group_offer_superadmin_feedback'
    create :feedback, volunteer: @other_volunteer, feedbackable: @group_offer,
      author: @superadmin, comments: 'other_volunteers_group_offer_feedback'
  end

  test 'volunteer can see assignment feedbacks index' do
    visit root_url
    click_link 'volunteer@example.com'
    click_link 'Show profile'
    within '.assignments-table' do
      click_link 'Feedback index'
    end
    refute page.has_text? 'author superadmin'
  end

  test 'volunteer can see group offer feedbacks index' do
    visit root_url
    click_link 'volunteer@example.com'
    click_link 'Show profile'
    within '.group-assignments-table' do
      click_link 'Feedback index'
    end
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
    other_group_offer = create :group_offer, title: 'some_other_group_offer',
      volunteers: [@volunteer, @other_volunteer], necessary_volunteers: 2
    create :feedback, volunteer: @volunteer, feedbackable: other_group_offer,
      author: @user_volunteer, comments: 'other_feedback'
    login_as @user_volunteer
    visit group_offer_feedbacks_path(@group_offer)
    assert page.has_text? 'some_group_offer_feedback'
    refute page.has_text? 'some_group_offer_superadmin_feedback'
    refute page.has_text? 'other_volunteers_group_offer_feedback'
    login_as @superadmin
    visit group_offer_feedbacks_path(@group_offer)
    assert page.has_text? 'some_group_offer_feedback'
    assert page.has_text? 'some_group_offer_superadmin_feedback'
    assert page.has_text? 'other_volunteers_group_offer_feedback'
  end

  test 'assignment feedbacks index contains only the feedbacks related to that assignment' do
    create :feedback, volunteer: @volunteer, author: @user_volunteer, feedbackable: @assignment,
      comments: 'some_feedback'
    create :feedback, volunteer: @volunteer, author: @superadmin, feedbackable: @assignment,
      comments: 'some_superadmin_feedback'
    other_assignment = create :assignment, volunteer: @volunteer
    create :feedback, feedbackable: other_assignment, volunteer: @volunteer,
      author: @user_volunteer, comments: 'other_feedback'
    login_as @user_volunteer
    visit assignment_feedbacks_path(@assignment)
    assert page.has_text? 'some_feedback'
    refute page.has_text? 'some_superadmin_feedback'
    refute page.has_text? 'other_feedback'
    login_as @superadmin
    visit assignment_feedbacks_path(@assignment)
    assert page.has_text? 'some_feedback'
    assert page.has_text? 'some_superadmin_feedback'
    refute page.has_text? 'other_feedback'
  end


  test 'volunteer feedbacks index contains only the feedbacks related to that group offer' do
    create :feedback, volunteer: @volunteer, author: @user_volunteer, feedbackable: @assignment,
      comments: 'some_assignment_feedback'
    create :feedback, volunteer: @volunteer, author: @superadmin, feedbackable: @assignment,
      comments: 'some_assignment_superadmin_feedback'
    other_assignment = create :assignment, volunteer: @volunteer
    create :feedback, feedbackable: other_assignment, volunteer: @volunteer,
      author: @user_volunteer, comments: 'other_assignment_feedback'
    login_as @user_volunteer
    visit volunteer_feedbacks_path(@assignment)
    assert page.has_text? 'some_assignment_feedback'
    refute page.has_text? 'some_assignment_superadmin_feedback'
    assert page.has_text? 'other_assignment_feedback'
    assert page.has_text? 'some_group_offer_feedback'
    refute page.has_text? 'some_group_offer_superadmin_feedback'
    refute page.has_text? 'other_volunteers_group_offer_feedback'
    login_as @superadmin
    visit volunteer_feedbacks_path(@assignment)
    assert page.has_text? 'some_assignment_feedback'
    assert page.has_text? 'some_assignment_superadmin_feedback'
    assert page.has_text? 'other_assignment_feedback'
    assert page.has_text? 'some_group_offer_feedback'
    assert page.has_text? 'some_group_offer_superadmin_feedback'
    refute page.has_text? 'other_volunteers_group_offer_feedback'
  end

  test 'volunteer can create only their feedbacks' do
    assignment = create :assignment, volunteer: create(:volunteer)
    visit new_assignment_feedback_path(assignment)
    assert page.has_text? 'You are not authorized to perform this action.'
  end

  test 'create new assignment feedback' do
    login_as @user_volunteer
    visit volunteer_path(@volunteer)
    within '.assignments-table' do
      click_link 'New Feedback'
    end
    fill_in 'Which were the most important goals during the last months?',
      with: 'important_goals_answer_given'
    fill_in 'What could have been achieved during the last months?',
      with: 'achievment_answer_given'
    fill_in 'Should the assignment continue? If yes, with which goals?',
      with: 'continue_answer_given'
    fill_in 'Comments', with: 'comments_given'
    page.check('feedback_conversation')
    click_button 'Create Feedback'
    assert page.has_text? 'Feedback was successfully created.'
    assert page.has_text? 'important_goals_answer_given'
    assert page.has_text? 'achievment_answer_given'
    assert page.has_text? 'continue_answer_given'
    assert page.has_text? 'comments_given'
  end

  test 'create new group_offer feedback' do
    login_as @user_volunteer
    visit volunteer_path(@volunteer)
    within '.group-assignments-table' do
      click_link 'New Feedback'
    end
    fill_in 'Which were the most important goals during the last months?',
      with: 'important_goals_answer_given'
    fill_in 'What could have been achieved during the last months?',
      with: 'achievment_answer_given'
    fill_in 'Should the assignment continue? If yes, with which goals?',
      with: 'continue_answer_given'
    fill_in 'Comments', with: 'new_comments_given'
    page.check('feedback_conversation')
    click_button 'Create Feedback'
    assert page.has_text? 'Feedback was successfully created.'
    assert page.has_text? 'important_goals_answer_given'
    assert page.has_text? 'achievment_answer_given'
    assert page.has_text? 'continue_answer_given'
    assert page.has_text? 'new_comments_given'
  end
end
