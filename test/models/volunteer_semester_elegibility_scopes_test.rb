require 'test_helper'

class VolunteerSemesterElegibilityScopesTest < ActiveSupport::TestCase
  def setup
    @volunteer = create :volunteer_with_user
    @assignment = create :assignment, volunteer: @volunteer, period_start: nil, period_end: nil
    @group_offer = create :group_offer
    @group_assignment = create :group_assignment, volunteer: @volunteer, group_offer: @group_offer,
      period_start: nil, period_end: nil

    @volunteer2 = create :volunteer_with_user
    @assignment2 = create :assignment, volunteer: @volunteer2, period_start: nil, period_end: nil
    @group_assignment2 = create :group_assignment, volunteer: @volunteer2, group_offer: @group_offer,
      period_start: nil, period_end: nil

    @volunteer3 = create :volunteer_with_user
    @assignment3 = create :assignment, volunteer: @volunteer3, period_start: nil, period_end: nil
    @group_offer3 = create :group_offer
    @group_assignment3 = create :group_assignment, volunteer: @volunteer3, group_offer: @group_offer3,
      period_start: nil, period_end: nil

    @volunteer4 = create :volunteer_with_user
    @assignment4 = create :assignment, volunteer: @volunteer4, period_start: nil, period_end: nil
    @group_offer4 = create :group_offer
    @group_assignment4 = create :group_assignment, volunteer: @volunteer4, group_offer: @group_offer4,
      period_start: nil, period_end: nil

    @semester = Semester.new
  end

  ## have_mission scope test
  #
  test 'Volunteer without active assignment is not in have_mission' do
    query = Volunteer.have_mission
    assert_not query.include? @volunteer
    assert_not query.include? @volunteer2
    assert_not query.include? @volunteer3
  end

  test 'volunteer with started assignment is in have_mission' do
    @assignment.update(period_start: 6.months.ago)
    query = Volunteer.have_mission
    assert query.include? @volunteer
    assert_not query.include? @volunteer2
    assert_not query.include? @volunteer3
  end

  test 'volunteer with started group_assignment is in have_mission' do
    @group_assignment.update(period_start: 6.months.ago)
    query = Volunteer.have_mission
    assert query.include? @volunteer
    assert_not query.include? @volunteer2
    assert_not query.include? @volunteer3
  end

  test 'volunteer with started group_and_assignment is in have_mission' do
    @group_assignment.update(period_start: 6.months.ago)
    @group_assignment2.update(period_start: 6.months.ago)
    @assignment2.update(period_start: 6.months.ago)
    query = Volunteer.have_mission
    assert query.include? @volunteer
    assert query.include? @volunteer2
    assert_not query.include? @volunteer3
  end

  ## active_semester_mission scope tests
  #
  test 'only volunteers with assignment started before semester end minus 4 weeks probation' do
    @assignment.update(period_start: @semester.previous.begin.advance(months: 2))

    @assignment2.update(period_start: @semester.previous.begin.advance(months: -10))

    @assignment3.update(period_start: @semester.previous.end.advance(weeks: -2))

    query = Volunteer.active_semester_mission(@semester.previous)
    assert query.include? @volunteer
    assert query.include? @volunteer2
    assert_not query.include? @volunteer3
    assert_not query.include? @volunteer4
  end

  test 'only volunteers with group_assignment started before semester end minus 4 weeks probation' do
    @group_assignment.update(period_start: @semester.previous.begin.advance(months: 2))
    @group_assignment2.update(period_start: @semester.previous.begin.advance(months: -10))
    @group_assignment3.update(period_start: @semester.previous.end.advance(weeks: -2))

    query = Volunteer.active_semester_mission(@semester.previous)
    assert query.include? @volunteer
    assert query.include? @volunteer2
    assert_not query.include? @volunteer3
    assert_not query.include? @volunteer4
  end

  test 'only volunteers with mixed mission case started before semester end minus 4 weeks probation' do
    @assignment.update(period_start: @semester.previous.begin.advance(months: 2))
    @group_assignment.update(period_start: @semester.previous.end.advance(weeks: -2))

    @assignment2.update(period_start: @semester.previous.begin.advance(months: 4))
    @group_assignment2.update(period_start: @semester.previous.end.advance(weeks: -2))

    @group_assignment3.update(period_start: @semester.previous.end.advance(weeks: -2))

    query = Volunteer.active_semester_mission(@semester.previous)
    assert query.include? @volunteer
    assert query.include? @volunteer2
    assert_not query.include? @volunteer3
    assert_not query.include? @volunteer4
  end

  ## have_semester_process scope tests
  #
  test 'have_semester_process only returns volunteers that have one in given semester' do
    create_semester_processes

    query = Volunteer.have_semester_process(@semester.previous)
    assert query.include? @volunteer
    assert_not query.include? @volunteer2
    assert query.include? @volunteer3
    assert_not query.include? @volunteer4

    query = Volunteer.have_semester_process(@semester.previous(2))
    assert_not query.include? @volunteer
    assert query.include? @volunteer2
    assert query.include? @volunteer3
    assert_not query.include? @volunteer4
  end

  ## #semester_process_eligible tests
  #
  test 'semester_process_eligible returns only volunteers elegible' do
    semester_process_prev, semester_process_prev2 = create_semester_processes

    query = Volunteer.semester_process_eligible(@semester.previous)
    assert_not query.include? @volunteer
    assert query.include? @volunteer2
    assert_not query.include? @volunteer3
    assert query.include? @volunteer4

    query = Volunteer.semester_process_eligible(@semester.previous(2))
    assert query.include? @volunteer
    assert_not query.include? @volunteer2
    assert_not query.include? @volunteer3
    assert query.include? @volunteer4
  end

  def create_semester_processes
    @assignment.update(period_start: 4.years.ago)
    @assignment2.update(period_start: 4.years.ago)
    @group_assignment3.update(period_start: 4.years.ago)
    @assignment3.update(period_start: 4.years.ago)
    @group_assignment4.update(period_start: 4.years.ago)

    semester_process_prev = SemesterProcess.create(creator: create(:user), semester: @semester.previous,
      semester_process_volunteers: [
        SemesterProcessVolunteer.new(volunteer: @volunteer, semester_process_volunteer_missions: [
          SemesterProcessVolunteerMission.new(assignment: @assignment)
        ]),
        SemesterProcessVolunteer.new(volunteer: @volunteer3, semester_process_volunteer_missions: [
          SemesterProcessVolunteerMission.new(group_assignment: @group_assignment3)
        ])
      ])

    semester_process_prev2 = SemesterProcess.create(creator: create(:user), semester: @semester.previous(2),
      semester_process_volunteers: [
        SemesterProcessVolunteer.new(volunteer: @volunteer2, semester_process_volunteer_missions: [
          SemesterProcessVolunteerMission.new(assignment: @assignment2)
        ]),
        SemesterProcessVolunteer.new(volunteer: @volunteer3, semester_process_volunteer_missions: [
          SemesterProcessVolunteerMission.new(group_assignment: @group_assignment3)
        ])
      ])

    [semester_process_prev, semester_process_prev2]
  end
end
