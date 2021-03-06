require 'application_system_test_case'

class FeedbacksTest < ApplicationSystemTestCase
  def setup
    @volunteer = create :volunteer
    @user_volunteer = @volunteer.user
    @assignment = create :assignment, volunteer: @volunteer, period_start: 7.weeks.ago
    @superadmin = create :user
    @other_volunteer = create :volunteer
    @group_offer = create :group_offer, necessary_volunteers: 2, title: 'some_group_offer'
    create :group_assignment, volunteer: @volunteer, group_offer: @group_offer
    create :group_assignment, volunteer: @other_volunteer, group_offer: @group_offer
  end

  def setup_feedbacks
    @assignment_volunteer_feedback = create :feedback, volunteer: @volunteer,
      author: @user_volunteer, feedbackable: @assignment,
      comments: 'author_volunteer_assignment_feedback'
    create :feedback, feedbackable: @assignment,
      volunteer: @volunteer, author: @superadmin, comments: 'author_superadmin_assignment_feedback'
    create :feedback, feedbackable: @group_offer, author: @user_volunteer,
      volunteer: @volunteer, comments: 'author_volunteer_group_offer_feedback'
    create :feedback, feedbackable: @group_offer, author: @superadmin, volunteer: @volunteer,
      comments: 'author_superadmin_group_offer_feedback'
    create :feedback, volunteer: @other_volunteer, feedbackable: @group_offer,
      author: @superadmin, comments: 'author_other_volunteer_group_offer_feedback'
  end

  test 'volunteer can see assignment feedbacks index' do
    setup_feedbacks
    login_as @user_volunteer
    visit root_url
    within '.navbar-top' do
      click_link I18n.t("role.#{@user_volunteer.role}"), href: '#'
    end
    click_link 'Profil bearbeiten'
    within '.assignments-table' do
      click_link 'Halbjahres-Rapport Liste', href: polymorphic_path([@volunteer, @assignment, Feedback])
    end
    refute page.has_text? 'author_superadmin_assignment_feedback'
    assert page.has_text? 'author_volunteer_assignment_feedback'
  end

  test 'volunteer can see group offer feedbacks index' do
    setup_feedbacks
    login_as @user_volunteer
    visit root_url
    within '.navbar-top' do
      click_link I18n.t("role.#{@user_volunteer.role}"), href: '#'
    end
    click_link 'Profil bearbeiten'
    within '.group-assignments-table' do
      click_link 'Halbjahres-Rapport Liste', href: polymorphic_path([@volunteer, @group_offer, Feedback])
    end
    refute page.has_text? 'author_superadmin_group_offer_feedback'
    assert page.has_text? 'author_volunteer_group_offer_feedback'
  end

  test 'assignment_feedback_index_contains_only_the_feedbacks_of_one_assignment' do
    setup_feedbacks
    login_as @user_volunteer
    visit volunteer_path(@user_volunteer.volunteer)
    within '.assignments-table' do
      click_link 'Halbjahres-Rapport Liste', href: polymorphic_path([@volunteer, @assignment, Feedback])
    end
    refute page.has_text? 'author_superadmin_assignment_feedback'
    assert page.has_text? 'author_volunteer_assignment_feedback'
  end

  test 'group offer feedbacks index contains only the feedbacks related to that group offer' do
    setup_feedbacks
    other_group_offer = create :group_offer, title: 'some_other_group_offer', necessary_volunteers: 2
    create :group_assignment, volunteer: @volunteer, group_offer: other_group_offer
    create :group_assignment, volunteer: @other_volunteer, group_offer: other_group_offer
    create :feedback, volunteer: @volunteer, feedbackable: other_group_offer,
      author: @user_volunteer, comments: 'same_volunteer_other_groupoffer_feedback'
    login_as @user_volunteer
    visit polymorphic_path([@volunteer, @group_offer, Feedback])
    assert page.has_text? 'author_volunteer_group_offer_feedback'
    refute page.has_text? 'author_superadmin_group_offer_feedback'
    refute page.has_text? 'author_other_volunteer_group_offer_feedback'
    refute page.has_text? 'same_volunteer_other_groupoffer_feedback'
    login_as @superadmin
    visit polymorphic_path([@volunteer, @group_offer, Feedback])
    assert page.has_text? 'author_volunteer_group_offer_feedback'
    assert page.has_text? 'author_superadmin_group_offer_feedback'
    assert page.has_text? 'author_other_volunteer_group_offer_feedback'
    refute page.has_text? 'same_volunteer_other_groupoffer_feedback'
  end

  test 'assignment feedbacks index contains only the feedbacks related to that assignment' do
    setup_feedbacks
    other_assignment = create :assignment, volunteer: @volunteer
    create :feedback, feedbackable: other_assignment, volunteer: @volunteer,
      author: @user_volunteer, comments: 'same_volunteer_other_assignment_feedback'
    login_as @user_volunteer
    visit polymorphic_path([@volunteer, @assignment, Feedback])
    assert page.has_text? 'author_volunteer_assignment_feedback'
    refute page.has_text? 'author_superadmin_assignment_feedback'
    refute page.has_text? 'same_volunteer_other_assignment_feedback'
    login_as @superadmin
    visit polymorphic_path([@volunteer, @assignment, Feedback])
    assert page.has_text? 'author_volunteer_assignment_feedback'
    assert page.has_text? 'author_superadmin_assignment_feedback'
    refute page.has_text? 'same_volunteer_other_assignment_feedback'
  end

  test 'volunteer can create only their feedbacks on assignment' do
    other_assignment = create :assignment, volunteer: create(:volunteer)
    login_as @user_volunteer
    visit new_polymorphic_path([@volunteer, other_assignment, Feedback])
    assert page.has_text? 'Sie sind nicht berechtigt diese Aktion durchzuführen.'
  end

  test 'volunteer can create only their feedbacks on group_offer' do
    other_group_offer = create :group_offer, necessary_volunteers: 2, title: 'other_group_offer'
    create :group_assignment, volunteer: create(:volunteer), group_offer: other_group_offer
    create :group_assignment, volunteer: create(:volunteer), group_offer: other_group_offer

    login_as @user_volunteer
    visit new_polymorphic_path([@volunteer, other_group_offer, Feedback])
    assert page.has_text? 'Sie sind nicht berechtigt diese Aktion durchzuführen.'
  end

  test 'create_new_assignment_feedback_as_volunteer' do
    login_as @user_volunteer
    play_create_new_assignment_feedback
  end

  test 'create new assignment feedback as superadmin' do
    login_as @superadmin
    play_create_new_assignment_feedback
  end

  test 'create new group_offer feedback as volunteer' do
    login_as @user_volunteer
    play_create_new_group_offer_feedback
  end

  test 'create new group_offer feedback as superadmin' do
    login_as @superadmin
    play_create_new_group_offer_feedback
  end

  FEEDBACK_FORM_FILL = [
    { text: 'important_goals_answer_given' , field: 'Was waren die wichtigsten Inhalte (oder Ziele) Ihres Einsatzes in den letzten Monaten?'},
    { text: 'achievment_answer_given' , field: 'Was konnte in den letzten Monaten erreicht werden?' },
    { text: 'continue_answer_given' , field: 'Soll der Einsatz weiterlaufen und wenn ja, mit welchen Inhalten (Zielen)?' },
    { text: 'new_comments_given', field: 'Bemerkungen' }
  ].freeze

  def play_create_new_assignment_feedback
    visit volunteer_path(@volunteer)
    within '.assignments-table' do
      click_link 'Halbjahres-Rapport erfassen'
    end
    FEEDBACK_FORM_FILL.each do |fill_values|
      fill_in fill_values[:field], with: fill_values[:text]
    end
    click_button 'Halbjahres-Rapport erfassen'
    assert page.has_text? 'Halbjahres-Rapport wurde erfolgreich erstellt.'
    within '.assignments-table' do
      click_link 'Halbjahres-Rapport Liste', href: polymorphic_path([@volunteer, @assignment, Feedback])
    end
    click_link 'Anzeigen'
    FEEDBACK_FORM_FILL.each do |fill_values|
      assert page.has_text? fill_values[:text]
    end
  end

  def play_create_new_group_offer_feedback
    visit volunteer_path(@volunteer)
    within '.group-assignments-table' do
      click_link 'Halbjahres-Rapport erfassen'
    end
    FEEDBACK_FORM_FILL.each do |fill_values|
      fill_in fill_values[:field], with: fill_values[:text]
    end
    click_button 'Halbjahres-Rapport erfassen'
    assert page.has_text? 'Halbjahres-Rapport wurde erfolgreich erstellt.'
    within '.group-assignments-table' do
      click_link 'Halbjahres-Rapport Liste', href: polymorphic_path([@volunteer, @group_offer, Feedback])
    end
    click_link 'Anzeigen'
    FEEDBACK_FORM_FILL.each do |fill_values|
      assert page.has_text? fill_values[:text]
    end
  end
end
