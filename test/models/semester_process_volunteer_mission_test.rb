require 'test_helper'

class SemesterProcessVolunteerMissionTest < ActiveSupport::TestCase
  def setup
    @assignment = create(:assignment)
    @volunteer = @assignment.volunteer
    @group_assignment = create(:group_assignment, volunteer: @volunteer)
    @sem_proc_vol = create(:semester_process_volunteer, volunteer: @volunteer)
    @subject = create(:semester_process_volunteer_mission, :no_mission,
      semester_process_volunteer: @sem_proc_vol)
  end

  test '#need_feedback' do
    @sem_proc_vol.semester_process.update!(semester: time_z(2018, 6, 1)..time_z(2018, 10, 31))
    @assignment.update!(period_end: nil)
    @group_assignment.update!(period_end: nil)
    mission1 = create(:semester_process_volunteer_mission, mission: @assignment, semester_process_volunteer: @sem_proc_vol)
    mission2 = create(:semester_process_volunteer_mission, mission: @group_assignment, semester_process_volunteer: @sem_proc_vol)
    assert_includes @sem_proc_vol.semester_process_volunteer_missions.need_feedback, mission1
    assert_includes @sem_proc_vol.semester_process_volunteer_missions.need_feedback, mission2
    @assignment.update!(period_end: time_z(2018, 5, 1))
    @group_assignment.update!(period_end: time_z(2017, 5, 1))
    assert_not_includes @sem_proc_vol.semester_process_volunteer_missions.need_feedback, mission1
    assert_not_includes @sem_proc_vol.semester_process_volunteer_missions.need_feedback, mission2
    @assignment.update!(period_end: time_z(2018, 7, 1))
    @group_assignment.update!(period_end: time_z(2018, 8, 1))
    assert_includes @sem_proc_vol.semester_process_volunteer_missions.need_feedback, mission1
    assert_includes @sem_proc_vol.semester_process_volunteer_missions.need_feedback, mission2
    @assignment.update!(period_end: time_z(2018, 12, 1))
    @group_assignment.update!(period_end: time_z(2019, 1, 20))
    assert_includes @sem_proc_vol.semester_process_volunteer_missions.need_feedback, mission1
    assert_includes @sem_proc_vol.semester_process_volunteer_missions.need_feedback, mission2
  end

  test 'its_invalid_if_no_mission_is_assigned' do
    assert_not @subject.valid?
    assert_equal :insuficient_relation, @subject.errors.details[:assignment].first[:error]
    assert_equal :insuficient_relation, @subject.errors.details[:group_assignment].first[:error]
  end

  test 'its invalid if it has assignment and group assignment' do
    @subject.assignment = @assignment
    @subject.group_assignment = @group_assignment
    assert_not @subject.valid?
    assert_equal :too_many_relations, @subject.errors.details[:assignment].first[:error]
    assert_equal :too_many_relations, @subject.errors.details[:group_assignment].first[:error]
  end

  test 'its_valid_if_it_has_assignment with #mission' do
    @subject.mission = @assignment
    assert @subject.valid?
  end

  test 'its_valid_if_it_has_group_assignment with #mission' do
    @subject.mission = @group_assignment
    assert @subject.valid?
  end

  test 'its_valid_if_it_has_assignment with' do
    @subject.assignment = @assignment
    assert @subject.valid?
  end

  test 'its_valid_if_it_has_group_assignment with' do
    @subject.group_assignment = @group_assignment
    assert @subject.valid?
  end
end
