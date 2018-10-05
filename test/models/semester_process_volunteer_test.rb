require 'test_helper'

class SemesterProcessVolunteerTest < ActiveSupport::TestCase
  def setup
    @volunteer = create(:volunteer_with_user)
    @assignment = create(:assignment, volunteer: @volunteer)
    @group_assignment = create(:group_assignment, volunteer: @volunteer)
    @subject = create(:semester_process_volunteer, volunteer: @volunteer)
  end

  test '#mission returns array with all kind of related assignment or group_assignments' do
    @subject.update(semester_process_volunteer_missions: [
      build(:semester_process_volunteer_mission, mission: @assignment),
      build(:semester_process_volunteer_mission, mission: @group_assignment)
    ])
    result = @subject.missions
    assert result.include? @assignment
    assert result.include? @group_assignment
  end

  test 'has_many mails and reminders relations work' do
    mail = create(:semester_process_mail, semester_process_volunteer: @subject)
    reminder = create(:semester_process_mail, :as_reminder, semester_process_volunteer: @subject)

    assert @subject.reload.mails.include? mail
    assert_not @subject.reload.mails.include? reminder

    assert_not @subject.reload.reminders.include? mail
    assert @subject.reload.reminders.include? reminder
  end
end
