require 'application_system_test_case'

class TerminateAssignmentsTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user
    @department_manager = create :department_manager
    @client = create :client, user: @department_manager
    @volunteer = create :volunteer_with_user
    @assignment = create :assignment, volunteer: @volunteer, client: @client,
      period_start: 10.weeks.ago, period_end: nil, creator: @department_manager
    @hour = create :hour, volunteer: @volunteer, hourable: @assignment
    @feedback = create :feedback, volunteer: @volunteer, feedbackable: @assignment,
      author: @volunteer.user
  end

  test 'volunteer_termination_submit_form_displays_existing_hours_and_feedbacks' do
    @assignment.update(period_end: 2.days.ago)
    login_as @volunteer.user
    visit terminate_assignment_path(@assignment)
    assert page.has_text?(/Die Begleitung (endet|wurde) am #{I18n.l(@assignment.period_end)}/)
    assert page.has_text? "#{I18n.l(@hour.meeting_date)} #{@hour.hours}:#{'%02i' % @hour.minutes} "\
      "#{@hour.activity} #{@hour.comments}"
    assert page.has_text? "#{@feedback.goals} #{@feedback.achievements} #{@feedback.future} "\
      "#{@feedback.comments} #{I18n.t(@feedback.conversation)}"
  end

  test 'volunteer_termination_form_creating_hours_redirects_back_to_form' do
    @assignment.update(period_end: 2.days.ago)
    login_as @volunteer.user
    visit terminate_assignment_path(@assignment)
    click_link 'New Hour report'
    assert page.has_text? @assignment.to_label
    select(1.year.ago.day, from: 'hour_meeting_date_3i')
    select(I18n.t('date.month_names')[1.year.ago.month], from: 'hour_meeting_date_2i')
    select(1.year.ago.year, from: 'hour_meeting_date_1i')
    select(3, from: 'hour_hours')
    fill_in 'Activity', with: 'my_tryout_activity_hour_thingie'
    fill_in 'Comments', with: 'my_tryout_commment_hour_thingie'
    click_button 'Create Hour report'
    assert page.has_text?(/Die Begleitung (endet|wurde) am #{I18n.l(@assignment.period_end)}/)
    assert page.has_text? 'my_tryout_activity_hour_thingie'
    assert page.has_text? 'my_tryout_commment_hour_thingie'
  end

  test 'volunteer_termination_form_creating_feedbacks_redirects_back_to_form' do
    @assignment.update(period_end: 2.days.ago)
    login_as @volunteer.user
    visit terminate_assignment_path(@assignment)
    click_link 'New Feedback'
    fill_in 'Comments', with: 'my_tryout_feedback_comment_text_to_find'
    click_button 'Create Feedback'
    assert page.has_text?(/Die Begleitung (endet|wurde) am #{I18n.l(@assignment.period_end)}/)
    assert page.has_text? 'my_tryout_feedback_comment_text_to_find'
  end

  test 'submitting_termination_sets_termination_submitted_at_and_termination_submitted_by' do
    @assignment.update(period_end: 2.days.ago)
    login_as @volunteer.user
    visit terminate_assignment_path(@assignment)
    click_link 'Beendigung Abschliessen'
    page.accept_confirm do
      click_button 'Einsatz wird hiermit abgeschlossen'
    end
    @assignment.reload
    assert @assignment.termination_submitted_at.present?
    assert_equal @volunteer.user, @assignment.termination_submitted_by
  end

  test 'termination triggers notification email to creator' do
    @assignment.update(period_end: 2.days.ago)
    login_as @volunteer.user
    visit terminate_assignment_path(@assignment)
    page.accept_confirm do
      click_button 'Einsatz wird hiermit abgeschlossen'
    end

    mail = ActionMailer::Base.deliveries.last
    assert_equal @department_manager.email, mail['to'].to_s
  end

  test 'superadmin_submitting_termination_sets_termination_submitted_at_and_termination_submitt' do
    @assignment.update(period_end: 2.days.ago)
    login_as @superadmin
    visit terminate_assignment_path(@assignment)
    click_link 'Beendigung Abschliessen'
    page.accept_confirm do
      click_button 'Einsatz wird hiermit abgeschlossen'
    end
    @assignment.reload
    assert @assignment.termination_submitted_at.present?
    assert_equal @superadmin, @assignment.termination_submitted_by
  end

  test 'department_manager_submitting_termination_sets_termination_submitted' do
    @assignment.update(period_end: 2.days.ago)
    login_as @department_manager
    visit terminate_assignment_path(@assignment)
    click_link 'Beendigung Abschliessen'
    page.accept_confirm do
      click_button 'Einsatz wird hiermit abgeschlossen'
    end
    @assignment.reload
    assert @assignment.termination_submitted_at.present?
    assert_equal @department_manager, @assignment.termination_submitted_by
  end

  test 'volunteer_expenses_waive_field_matches_and_updates_volunteer_waive_field' do
    @assignment.update(period_end: 2.days.ago)
    login_as @volunteer.user
    visit terminate_assignment_path(@assignment)
    click_link 'Beendigung Abschliessen'
    refute page.find_field('I waived the compensation of my expenses.').checked?
    page.check('assignment_volunteer_attributes_waive')
    page.accept_confirm do
      click_button 'Einsatz wird hiermit abgeschlossen'
    end
    @volunteer.reload
    assert @volunteer.waive
  end
end
