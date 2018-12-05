require 'application_system_test_case'

class SemesterProcessVolunteersTest < ApplicationSystemTestCase
  setup do
    @current_semester = Semester.new
    @one_semester_back = create :semester_process, :with_volunteers, semester: @current_semester.previous_s
    @two_semesters_back = create :semester_process, :with_volunteers, semester: @current_semester.previous_s(2)
    @three_semesters_back = create :semester_process, :with_volunteers, semester: @current_semester.previous_s(3)
    login_as create(:user)
    visit semester_process_volunteers_path(semester: Semester.to_s(@one_semester_back.semester))
  end

  test 'filter semester process volunteer shows previous semester by default' do
    assert page.has_text? @one_semester_back.semester_process_volunteers.first.semester_feedbacks.first.goals
    assert_not page.has_text? @two_semesters_back.semester_process_volunteers.first.semester_feedbacks.first.goals
  end

  test 'filter semester process volunteer on semester' do
    click_button "Semester: #{@current_semester.collection.second[1]}", match: :first
    click_link @two_semesters_back.semester_t
    assert_not page.has_text? @one_semester_back.semester_process_volunteers.first.semester_feedbacks.first.goals
    assert page.has_text? @two_semesters_back.semester_process_volunteers.first.semester_feedbacks.first.goals
    assert_not page.has_text? @three_semesters_back.semester_process_volunteers.first.semester_feedbacks.first.goals
  end

  test 'New semester process after filtering on index preserves semester selection' do
    create :email_template, :half_year_process_email
    click_button "Semester: #{@current_semester.collection.second[1]}", match: :first
    click_link @three_semesters_back.semester_t
    click_on 'Neuen Semester Prozess erstellen', match: :first
    assert page.has_select? 'Semester', selected: @current_semester.unique_collection.last[0]
  end
end
