require 'application_system_test_case'

class SemesterFeedbackTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user
    @volunteer = create :volunteer_with_user
    @assignment = create :assignment, volunteer: @volunteer
    @group_assignment = create :group_assignment, volunteer: @volunteer
    @subject = create :semester_process
    @subject_volunteer = create(:semester_process_volunteer, :with_mission, volunteer: @volunteer,
      semester_process: @subject)
    @mission = @subject_volunteer.semester_process_volunteer_missions.first.assignment
    login_as @superadmin
    visit review_semester_semester_process_volunteer_path(@subject_volunteer)
  end

  test 'by default, you should have not accepted the data' do
    assert_text 'Ich bestätige, dass ich alle meine Stunden und Halbjahres-Rapporte bis zum heutigen Datum erfasst habe.'
  end

  test 'accepting should remove submit button' do
    click_on 'Bestätigen', match: :first
    @subject_volunteer.reload
    assert_text "Bestätigt am #{I18n.l(@subject_volunteer.commited_at.to_date)} durch #{(@subject_volunteer.commited_by.full_name)}"
  end

  test 'you should be able to add hours on run' do
    assert_equal @subject_volunteer.hours.count, 0
    fill_in 'Stunden', with: 10
    click_on 'Bestätigen', match: :first
    @subject_volunteer.reload
    assert_equal @subject_volunteer.hours.first.hours, 10
    within '.table.table-striped.hours-table' do
      assert_text "#{I18n.l(Time.zone.now.to_date)} 10.0"
    end
  end

  test 'iban and bank has to be filled' do
    uncheck 'Ich verzichte auf die Auszahlung von Spesen.'
    fill_in 'IBAN', with: ''
    fill_in 'Bank', with: ''
    click_on 'Bestätigen', match: :first
    assert_text 'Es sind Fehler aufgetreten. Bitte überprüfen Sie die rot markierten Felder.'
    within '#volunteer-update-waive-and-iban' do
      assert_text 'Name der Bank darf nicht leer sein'
      assert_text 'IBAN darf nicht leer sein'
    end
  end

  test 'it should store the info that user inputs' do
    fill_in 'Was waren die wichtigsten Inhalte (oder Ziele) Ihres Einsatzes in den letzten Monaten?', with: 'being on time'
    fill_in 'Was konnte in den letzten Monaten erreicht werden?', with: 'everything'
    fill_in 'Soll der Einsatz weiterlaufen und wenn ja, mit welchen Inhalten (Zielen)?', with: 'continue'
    fill_in 'Kommentare', with: 'nothing'
    check 'Ich wünsche ein Gespräch mit meiner/meinem Freiwilligenverantwortlichen.'
    fill_in 'Stunden', with: 33
    uncheck 'Ich verzichte auf die Auszahlung von Spesen.'
    fill_in 'IBAN', with: 'CH59 2012 0767 0052 0024 0'
    fill_in 'Name der Bank', with: 'Bank'
    click_on 'Bestätigen'
    @subject_volunteer.reload
    assert_equal @subject_volunteer.volunteer.slice(:iban, :bank, :waive),
      { iban: 'CH59 2012 0767 0052 0024 0', bank: 'Bank', waive: false }.stringify_keys
    assert_equal @subject_volunteer.semester_feedbacks.last.slice(:goals, :achievements, :future, :comments, :conversation),
      { goals: 'being on time', achievements: 'everything', future: 'continue', comments: 'nothing', conversation: true }.stringify_keys
    assert_equal @subject_volunteer.hours.last.hours, 33
  end
end
