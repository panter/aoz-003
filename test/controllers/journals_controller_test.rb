require 'test_helper'

class JournalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @superadmin = create :user
    @reminder_mailing = create :reminder_mailing, :half_year
    @assignment = @reminder_mailing.reminder_mailing_volunteers.first.reminder_mailable
    @volunteer = @assignment.volunteer
    @feedback = create :feedback, feedbackable: @assignment, volunteer: @volunteer, author: @volunteer.user
  end

  test '#new prefilles with feedback quote if feedback_id param is passed' do
    login_as @superadmin
    get new_volunteer_journal_path(@volunteer, feedback_id: @feedback.id)
    @journal = @controller.instance_variable_get(:@journal)
    assert_equal @journal.category, 'feedback'
    assert_equal @journal.title, "Feedback vom #{I18n.l(@feedback.created_at.to_date)}: "
    assert @journal.body.include? @feedback.goals
    assert @journal.body.include? @feedback.achievements
    assert @journal.body.include? @feedback.future
    assert @journal.body.include? @feedback.comments
  end
end
