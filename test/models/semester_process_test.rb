require 'test_helper'

class SemesterProcessTest < ActiveSupport::TestCase
  def setup
    @superadmin = create :user
    @volunteer = create :volunteer_with_user
    @assignment = create :assignment, volunteer: @volunteer
    @group_assignment = create :group_assignment, volunteer: @volunteer
    @subject = create :semester_process
    @subject_volunteer = create(:semester_process_volunteer, :with_mission, volunteer: @volunteer,
      semester_process: @subject)
    @mission = @subject_volunteer.semester_process_volunteer_missions.first.assignment
    @subject.reload
  end

  test 'through volunteers relation' do
    assert @subject.volunteers.include? @volunteer
  end

  test 'through semester_feedbacks relation' do
    semester_fb = create(:semester_feedback, semester_process_volunteer: @subject_volunteer,
      volunteer: @volunteer)
    @subject.reload
    assert @subject.semester_feedbacks.include? semester_fb
  end

  test 'through hours relation' do
    semester_hour = create(:hour, hourable: @mission, volunteer: @volunteer,
      semester_process_volunteer: @subject_volunteer)
    @subject.reload
    assert @subject.hours.include? semester_hour
  end

  test '#mails and #reminders methods' do
    semester_process_mail = create(:semester_process_mail,
      semester_process_volunteer: @subject_volunteer)
    semester_process_reminder = create(:semester_process_mail, :as_reminder,
      semester_process_volunteer: @subject_volunteer)
    @subject.reload
    assert @subject.mails.include? semester_process_mail
    assert_not @subject.mails.include? semester_process_reminder
    assert @subject.reminders.include? semester_process_reminder
    assert_not @subject.reminders.include? semester_process_mail
  end
end
