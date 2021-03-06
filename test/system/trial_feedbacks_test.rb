require 'application_system_test_case'

class TrialFeedbacksTest < ApplicationSystemTestCase
  def setup
    use_rack_driver
    @volunteer = create :volunteer
    @user_volunteer = @volunteer.user
    @assignment = create :assignment, volunteer: @volunteer
    @superadmin = create :user
    @other_volunteer = create :volunteer
    @group_offer = create :group_offer, title: 'some_group_offer'
    create :group_assignment, volunteer: @volunteer, group_offer: @group_offer
    create :group_assignment, volunteer: @other_volunteer, group_offer: @group_offer
  end

  def setup_feedbacks
    @assignment_volunteer_feedback = create :trial_feedback, volunteer: @volunteer,
      author: @user_volunteer, trial_feedbackable: @assignment,
      body: 'author_volunteer_assignment_feedback'
    create :trial_feedback, trial_feedbackable: @assignment,
      volunteer: @volunteer, author: @superadmin, body: 'author_superadmin_assignment_feedback'
    create :trial_feedback, trial_feedbackable: @group_offer, author: @user_volunteer,
      volunteer: @volunteer, body: 'author_volunteer_group_offer_feedback'
    create :trial_feedback, trial_feedbackable: @group_offer, author: @superadmin,
      volunteer: @volunteer, body: 'author_superadmin_group_offer_feedback'
    create :trial_feedback, volunteer: @other_volunteer, trial_feedbackable: @group_offer,
      author: @superadmin, body: 'author_other_volunteer_group_offer_feedback'
  end

  test 'volunteer_can_see_assignment_trial_feedbacks_index' do
    setup_feedbacks
    login_as @user_volunteer
    visit root_url
    within '.navbar-top' do
      click_link I18n.t("role.#{@user_volunteer.role}"), href: '#'
    end
    click_link 'Profil bearbeiten'
    within '.assignments-table' do
      click_link 'Probezeit Feedback Liste'
    end
    refute page.has_text? 'author_superadmin_assignment_feedback'
    assert page.has_text? 'author_volunteer_assignment_feedback'
  end

  test 'volunteer_can_see_group_offer_trial_feedbacks_index' do
    setup_feedbacks
    login_as @user_volunteer
    visit root_url
    within '.navbar-top' do
      click_link I18n.t("role.#{@user_volunteer.role}"), href: '#'
    end
    click_link 'Profil bearbeiten'
    within '.group-assignments-table' do
      click_link 'Probezeit Feedback Liste'
    end
    refute page.has_text? 'author_superadmin_group_offer_feedback'
    assert page.has_text? 'author_volunteer_group_offer_feedback'
  end

  test 'assignment_trial_feedback_index_contains_only_the_feedbacks_of_one_assignment' do
    setup_feedbacks
    login_as @user_volunteer
    visit polymorphic_path([@volunteer, @assignment, @assignment_volunteer_feedback])
    click_link 'Zurück'
    within '.assignments-table' do
      click_link 'Probezeit Feedback Liste'
    end
    refute page.has_text? 'author_superadmin_assignment_feedback'
    assert page.has_text? 'author_volunteer_assignment_feedback'
  end

  test 'group_offer_trial_feedbacks_index_contains_only_feedbacks_related_to_that_group_offer' do
    setup_feedbacks
    other_group_offer = create :group_offer, title: 'some_other_group_offer'
    create :group_assignment, volunteer: @volunteer, group_offer: other_group_offer
    create :group_assignment, volunteer: @other_volunteer, group_offer: other_group_offer
    create :trial_feedback, volunteer: @volunteer, trial_feedbackable: other_group_offer,
      author: @user_volunteer, body: 'same_volunteer_other_groupoffer_feedback'
    login_as @user_volunteer
    visit polymorphic_path([@volunteer, @group_offer, TrialFeedback])
    assert page.has_text? 'author_volunteer_group_offer_feedback'
    refute page.has_text? 'author_superadmin_group_offer_feedback'
    refute page.has_text? 'author_other_volunteer_group_offer_feedback'
    refute page.has_text? 'same_volunteer_other_groupoffer_feedback'
    login_as @superadmin
    visit polymorphic_path([@volunteer, @group_offer, TrialFeedback])
    assert page.has_text? 'author_volunteer_group_offer_feedback'
    assert page.has_text? 'author_superadmin_group_offer_feedback'
    assert page.has_text? 'author_other_volunteer_group_offer_feedback'
    refute page.has_text? 'same_volunteer_other_groupoffer_feedback'
  end

  test 'assignment_trial_feedbacks_index_contains_only_the_feedbacks_related_to_that_assignment' do
    setup_feedbacks
    other_assignment = create :assignment, volunteer: @volunteer
    create :trial_feedback, trial_feedbackable: other_assignment, volunteer: @volunteer,
      author: @user_volunteer, body: 'same_volunteer_other_assignment_feedback'
    login_as @user_volunteer
    visit polymorphic_path([@volunteer, @assignment, TrialFeedback])
    assert page.has_text? 'author_volunteer_assignment_feedback'
    refute page.has_text? 'author_superadmin_assignment_feedback'
    refute page.has_text? 'same_volunteer_other_assignment_feedback'
    login_as @superadmin
    visit polymorphic_path([@volunteer, @assignment, TrialFeedback])
    assert page.has_text? 'author_volunteer_assignment_feedback'
    assert page.has_text? 'author_superadmin_assignment_feedback'
    refute page.has_text? 'same_volunteer_other_assignment_feedback'
  end

  test 'volunteer_can_create_only_their_trial_feedbacks_on_assignment' do
    other_assignment = create :assignment,
      volunteer: create(:volunteer)
    login_as @user_volunteer
    visit new_polymorphic_path([@volunteer, other_assignment, TrialFeedback])
    assert page.has_text? 'Sie sind nicht berechtigt diese Aktion durchzuführen.'
  end

  test 'volunteer_can_create_only_their_trial_feedbacks_on_group_offer' do
    other_group_offer = create :group_offer, title: 'other_group_offer'
    create :group_assignment, volunteer: create(:volunteer), group_offer: other_group_offer
    create :group_assignment, volunteer: create(:volunteer), group_offer: other_group_offer
    login_as @user_volunteer
    visit new_polymorphic_path([@volunteer, other_group_offer, TrialFeedback])
    assert page.has_text? 'Sie sind nicht berechtigt diese Aktion durchzuführen.'
  end

  test 'create_new_assignment_trial_feedback_as_volunteer' do
    login_as @user_volunteer
    play_create_new_assignment_feedback
  end

  test 'create_new_assignment_trial_feedback_as_superadmin' do
    login_as @superadmin
    play_create_new_assignment_feedback
  end

  test 'create_new_group_offer_trial_feedback_as_volunteer' do
    login_as @user_volunteer
    play_create_new_group_offer_feedback
  end

  test 'create_new_group_offer_trial_feedback_as_superadmin' do
    login_as @superadmin
    play_create_new_group_offer_feedback
  end

  def play_create_new_assignment_feedback
    visit volunteer_path(@volunteer)
    within '.assignments-table' do
      click_link 'Probezeit Feedback erfassen'
    end
    fill_in 'Text', with: 'Probezeit assignment feedback text'
    click_button 'Probezeit Feedback erfassen'
    assert page.has_text? 'Probezeit Feedback wurde erfolgreich erstellt.'
    within '.assignments-table' do
      click_link 'Probezeit Feedback Liste'
    end
    click_link 'Anzeigen'
    assert page.has_text? 'Probezeit assignment feedback text'
  end

  def play_create_new_group_offer_feedback
    visit volunteer_path(@volunteer)
    within '.group-assignments-table' do
      click_link 'Probezeit Feedback erfassen'
    end
    fill_in 'Text', with: 'Probezeit group assignment feedback text'
    click_button 'Probezeit Feedback erfassen'
    assert page.has_text? 'Probezeit Feedback wurde erfolgreich erstellt.'
    within '.group-assignments-table' do
      click_link 'Probezeit Feedback Liste'
    end
    click_link 'Anzeigen'
    assert page.has_text? 'Probezeit group assignment feedback text'
  end
end
