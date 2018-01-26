require 'application_system_test_case'

class GroupAssignmentTerminatesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @volunteer = create :volunteer_with_user, salutation: 'mrs'
    @group_offer = create :group_offer, creator: @superadmin
    @group_assignment = create :group_assignment, volunteer: @volunteer, group_offer: @group_offer,
      period_start: 20.days.ago, period_end: 10.days.ago, period_end_set_by: @superadmin
    @hour = create :hour, volunteer: @volunteer, hourable: @group_offer, hours: 2, minutes: 45
    @feedback = create :feedback, volunteer: @volunteer, author: @volunteer.user,
      feedbackable: @group_offer

    @unrelated_group_assignment = create :group_assignment, group_offer: @group_offer
    @unrelated_hour = create :hour, volunteer: @unrelated_group_assignment.volunteer,
      hourable: @group_offer, hours: 5, minutes: 15
    @unrelated_feedback = create :feedback, volunteer: @unrelated_group_assignment.volunteer,
      author: @unrelated_group_assignment.volunteer.user, feedbackable: @group_offer
  end

  test 'volunteer_can_use_group_assignment_terminate_form' do
    login_as @volunteer.user
    visit terminate_group_assignment_path(@group_assignment)
    assert page.has_text?(/Der Einsatz (wurde|endet) am #{I18n.l(@group_assignment.period_end)}/)
    assert page.has_text? "Die Freiwillige: #{@volunteer.contact.natural_name}"
    assert page.has_text? "Das Gruppenangebot #{@group_offer.title} -
      #{@group_offer.group_offer_category.category_name}"

    # Existing hour is listed
    within '.hours-table' do
      assert page.has_text? I18n.l(@hour.meeting_date)
      assert page.has_text? "#{@hour.hours}:#{'%02i' % @hour.minutes}"
      refute page.has_text? I18n.l(@unrelated_hour.meeting_date)
      refute page.has_text? "#{@unrelated_hour.hours}:#{'%02i' % @unrelated_hour.minutes}"
    end

    # existing feedback listed
    within '.feedbacks-table' do
      assert page.has_text? @feedback.goals
      assert page.has_text? @feedback.achievements
      assert page.has_text? @feedback.future
      assert page.has_text? @feedback.comments
      refute page.has_text? @unrelated_feedback.goals
      refute page.has_text? @unrelated_feedback.achievements
      refute page.has_text? @unrelated_feedback.future
      refute page.has_text? @unrelated_feedback.comments
    end

    fill_in 'Was waren Ihre Hauptaktivitäten während des Einsatzes?', with: 'rand_activities_text'
    fill_in 'Welche Erfolge oder Highlights haben Sie während Ihres Einsatzes erlebt?',
      with: 'rand_success_text'
    fill_in 'Welchen Schwierigkeiten in Bezug auf Ihren Einsatz sind Sie begegnet?',
      with: 'rand_trouble_text'
    fill_in 'Wie fanden Sie die von TransFair angebotene Unterstützung inklusive Weiterbildungen und '\
      'Anlässe?', with: 'rand_transfair_text'

    page.accept_confirm do
      click_button 'Einsatz wird hiermit abgeschlossen'
    end

    assert page.has_text? 'Der Gruppeneinsatz ist hiermit abgeschlossen.'

    @group_assignment.reload
    assert_equal @volunteer.user, @group_assignment.termination_submitted_by
    assert @group_assignment.termination_submitted_at.present?
    assert_equal 'rand_activities_text', @group_assignment.term_feedback_activities
    assert_equal 'rand_success_text', @group_assignment.term_feedback_success
    assert_equal 'rand_trouble_text', @group_assignment.term_feedback_problems
    assert_equal 'rand_transfair_text', @group_assignment.term_feedback_transfair
  end

  test 'adding_hour_redirect_back_works' do
    login_as @volunteer.user
    visit terminate_group_assignment_path(@group_assignment)
    click_link 'New Hour report'
    assert page.has_text? @group_assignment.group_offer.to_label
    test_date = 1.year.ago
    select(test_date.day, from: 'hour_meeting_date_3i')
    select(I18n.t('date.month_names')[test_date.month], from: 'hour_meeting_date_2i')
    select(test_date.year, from: 'hour_meeting_date_1i')
    select(3, from: 'hour_hours')
    fill_in 'Activity', with: 'my_tryout_activity_hour_thingie'
    fill_in 'Comments', with: 'my_tryout_commment_hour_thingie'
    click_button 'Create Hour report'
    assert page.has_text? 'Hour report was successfully created.'

    within '.hours-table' do
      assert page.has_text? "3:#{'%02i' % 0}"
      assert page.has_text? 'my_tryout_activity_hour_thingie'
      assert page.has_text? 'my_tryout_commment_hour_thingie'
    end
  end

  test 'adding_feedback_redirect_back_works' do
    login_as @volunteer.user
    visit terminate_group_assignment_path(@group_assignment)
    click_link 'New Feedback'
    fill_in 'Comments', with: 'my_newly_added_feedback_comment_text'
    click_button 'Create Feedback'

    within '.feedbacks-table' do
      assert page.has_text? 'my_newly_added_feedback_comment_text'
    end
  end
end
