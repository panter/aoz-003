require 'test_helper'

class JournalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @superadmin = create :user
    @reminder_mailing = create :reminder_mailing, :trial_period
    @assignment = @reminder_mailing.reminder_mailing_volunteers.first.reminder_mailable
    @volunteer = @assignment.volunteer
    @feedback = create :feedback, feedbackable: @assignment, volunteer: @volunteer, author: @volunteer.user
    login_as @superadmin
  end

  test '#new prefilles with feedback quote if feedback_id param is passed for trial period' do
    get new_volunteer_journal_path(@volunteer, feedback_id: @feedback.id)
    @journal = @controller.instance_variable_get(:@journal)
    assert_equal @journal.category, 'feedback'
    assert_equal @journal.title, "Feedback vom #{I18n.l(@feedback.created_at.to_date)}: "
    assert @journal.body.include? @feedback.goals
    assert @journal.body.include? @feedback.achievements
    assert @journal.body.include? @feedback.future
    assert @journal.body.include? @feedback.comments
  end

  test '#new prefilling for semester feedback quote if semester_feedback_id param is passed works also' do
    @spv = create(:semester_process_volunteer, volunteer: @volunteer)
    @semester_feedback = create(:semester_feedback, :no_mission, semester_process_volunteer: @spv, volunteer: @volunteer)

    get new_volunteer_journal_path(@volunteer, semester_feedback_id: @semester_feedback.id)
    @journal = @controller.instance_variable_get(:@journal)
    assert_equal @journal.category, 'feedback'
    assert_equal @journal.title, "Semester Prozess Feedback vom #{I18n.l(@semester_feedback.created_at.to_date)}: "
    assert @journal.body.include? @semester_feedback.goals
    assert @journal.body.include? @semester_feedback.achievements
    assert @journal.body.include? @semester_feedback.future
    assert @journal.body.include? @semester_feedback.comments
  end
end
