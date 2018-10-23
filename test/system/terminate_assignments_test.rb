require 'application_system_test_case'

class TerminateAssignmentsTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user
    @department_manager = create :department_manager
    @client = create :client, user: @department_manager
    @volunteer = create :volunteer, waive: false
    @assignment = create :assignment, volunteer: @volunteer, client: @client,
      period_start: 10.weeks.ago, period_end: 2.days.ago, creator: @department_manager
    @hour = create :hour, volunteer: @volunteer, hourable: @assignment
    @feedback = create :feedback, volunteer: @volunteer, feedbackable: @assignment,
      author: @volunteer.user
  end

  test 'assignment_termination_submit_form_displays_existing_hours_and_feedbacks' do
    login_as @superadmin
    visit terminate_assignment_path(@assignment)
    assert page.has_text?(/Die Begleitung (endet|wurde) am #{I18n.l(@assignment.period_end)}/)
    assert page.has_text? @assignment.volunteer.hours.total_hours
  end

  test 'assignment_termination_form_adds_remaining_hours' do
    login_as @superadmin
    visit terminate_assignment_path(@assignment)
    fill_in 'Restliche Stunden', with: '12.35'

    page.accept_confirm do
      click_on 'Einsatz wird hiermit abgeschlossen'
    end

    visit volunteer_hours_path(@volunteer)
    assert_text '12.35'
  end

  test 'submitting_termination_sets_termination_submitted_at_and_termination_submitted_by' do
    login_as @superadmin
    visit terminate_assignment_path(@assignment)
    page.accept_confirm do
      click_button 'Einsatz wird hiermit abgeschlossen'
    end
    @assignment.reload
    assert @assignment.termination_submitted_at.present?
    assert_equal @superadmin, @assignment.termination_submitted_by
  end

  test 'termination triggers notification email to creator' do
    login_as @superadmin
    visit terminate_assignment_path(@assignment)
    page.accept_confirm do
      click_button 'Einsatz wird hiermit abgeschlossen'
    end

    mail = ActionMailer::Base.deliveries.last
    assert_equal @department_manager.email, mail['to'].to_s
  end

  test 'superadmin_submitting_termination_sets_termination_submitted_at_and_termination_submitt' do
    login_as @superadmin
    visit terminate_assignment_path(@assignment)
    page.accept_confirm do
      click_button 'Einsatz wird hiermit abgeschlossen'
    end
    @assignment.reload
    assert @assignment.termination_submitted_at.present?
    assert_equal @superadmin, @assignment.termination_submitted_by
  end

  test 'department_manager_submitting_termination_sets_termination_submitted' do
    login_as @department_manager
    visit terminate_assignment_path(@assignment)
    page.accept_confirm do
      click_button 'Einsatz wird hiermit abgeschlossen'
    end
    @assignment.reload
    assert @assignment.termination_submitted_at.present?
    assert_equal @department_manager, @assignment.termination_submitted_by
  end

  test 'volunteer_expenses_waive_field_matches_and_updates_volunteer_waive_field' do
    login_as @superadmin
    visit terminate_assignment_path(@assignment)

    refute page.find_field('Ich verzichte auf die Auszahlung von Spesen.').checked?

    check 'Ich verzichte auf die Auszahlung von Spesen.'

    page.accept_confirm do
      click_button 'Einsatz wird hiermit abgeschlossen'
    end
    @volunteer.reload
    assert @volunteer.waive
  end

  test 'terminate_assignment_without_feedback_or_hours' do
    Hour.destroy_all
    Feedback.destroy_all

    login_as @superadmin
    visit terminate_assignment_path(@assignment)

    page.accept_confirm do
      click_on 'Einsatz wird hiermit abgeschlossen'
    end

    visit terminate_assignment_path(@assignment)
    assert_text "Beendigungs Feedback vom #{I18n.l Time.zone.today}"
  end
end
