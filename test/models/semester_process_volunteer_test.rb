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

  test '#build_missions' do
    travel_to time_z(2018, 7, 15)
    semester = Semester.new
    semester_process = SemesterProcess.new(semester: semester.previous, creator: create(:user))

    @assignment.update(period_start: nil, period_end: nil)
    @group_assignment.update(period_start: nil, period_end: nil)

    subject = SemesterProcessVolunteer.new(semester_process: semester_process, volunteer: @volunteer)
    subject.build_missions(semester.previous)
    assert_equal 0, subject.semester_process_volunteer_missions.size

    @assignment.update(period_start: time_z(2015, 7, 15))
    subject = SemesterProcessVolunteer.new(semester_process: semester_process, volunteer: @volunteer)
    subject.build_missions(semester.previous)
    assert_equal 1, subject.semester_process_volunteer_missions.size

    @group_assignment.update(period_start: time_z(2018, 7, 1))
    subject = SemesterProcessVolunteer.new(semester_process: semester_process, volunteer: @volunteer)
    subject.build_missions(semester.previous)
    assert_equal 1, subject.semester_process_volunteer_missions.size

    @group_assignment.update(period_start: time_z(2018, 7, 1).advance(weeks: -2))
    subject = SemesterProcessVolunteer.new(semester_process: semester_process, volunteer: @volunteer)
    subject.build_missions(semester.previous)
    assert_equal 1, subject.semester_process_volunteer_missions.size
  end

  test '#build_mails' do
    travel_to time_z(2018, 7, 15)
    semester = Semester.new
    semester_process = SemesterProcess.new(semester: semester.previous, creator: create(:user))

    @assignment.update(period_start: time_z(2018, 1, 15), period_end: nil)
    @group_assignment.update(period_start: time_z(2018, 1, 15), period_end: nil)
    hour_assignment = create :hour, hourable: @assignment, meeting_date: time_z(2018, 3, 15),
      volunteer: @volunteer

    subject = SemesterProcessVolunteer.new(semester_process: semester_process, volunteer: @volunteer)
    subject.build_missions(semester.previous)
    subject.build_mails
    assert subject.hours.include? hour_assignment

    hour_group_assignment = create :hour, hourable: @group_assignment.group_offer,
      meeting_date: time_z(2018, 3, 15), volunteer: @volunteer

    subject = SemesterProcessVolunteer.new(semester_process: semester_process, volunteer: @volunteer)
    subject.build_missions(semester.previous)
    subject.build_mails
    assert subject.hours.include? hour_assignment
    assert subject.hours.include? hour_group_assignment
  end
end
