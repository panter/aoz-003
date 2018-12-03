require 'application_system_test_case'

class SemesterFeedbackTest < ApplicationSystemTestCase
  setup do
    @volunteer = create :volunteer_with_user
    @subject = create :semester_process
    @spv = create(:semester_process_volunteer, :with_mission, volunteer: @volunteer,
      semester_process: @subject)
    login_as @volunteer.user
    visit review_semester_semester_process_volunteer_path(@spv)
  end

  def submit_feedback(semester_process_volunteer)
    visit review_semester_semester_process_volunteer_path(semester_process_volunteer)
    fill_in_required_feedback_fields
    check 'Ich verzichte auf die Auszahlung von Spesen.'
    click_on 'Bestätigen', match: :first
    semester_process_volunteer.reload
  end

  def fill_in_required_feedback_fields
    fill_in 'Was waren die wichtigsten Inhalte (oder Ziele) Ihres Einsatzes in den letzten Monaten?', with: 'being on time'
    fill_in 'Was konnte in den letzten Monaten erreicht werden?', with: 'everything'
    fill_in 'Soll der Einsatz weiterlaufen und wenn ja, mit welchen Inhalten (Zielen)?', with: 'continue'
  end

  test 'volunteer with unsubmitted feedback should see a warning' do
    visit volunteer_path(@volunteer)
    assert page.has_text? 'Sie haben einen ausstehenden Halbjahres-Rapport für dieses Semester.'
    assert page.has_link? 'Bitte klicken Sie hier um diesen zu bestätigen'
    visit root_path
    assert page.has_text? 'Sie haben einen ausstehenden Halbjahres-Rapport für dieses Semester.'
    assert page.has_link? 'Bitte klicken Sie hier um diesen zu bestätigen'
    click_link 'Bitte klicken Sie hier um diesen zu bestätigen'
    submit_feedback(@spv)
    visit volunteer_path(@volunteer)
    assert_not page.has_text? 'Sie haben einen ausstehenden Halbjahres-Rapport für dieses Semester.'
    visit root_path
    assert_not page.has_text? 'Sie haben einen ausstehenden Halbjahres-Rapport für dieses Semester.'
  end

  test 'submit form should not display warning' do
    visit root_path
    assert page.has_text? 'Sie haben einen ausstehenden Halbjahres-Rapport für dieses Semester.'
    click_link 'Bitte klicken Sie hier um diesen zu bestätigen'
    assert_not page.has_text? 'Sie haben einen ausstehenden Halbjahres-Rapport für dieses Semester.'
  end

  test 'by default, you should have not accepted the data' do
    assert_text 'Ich bestätige, dass ich alle meine Stunden und Halbjahres-Rapporte bis zum heutigen Datum erfasst habe.'
  end

  test 'accepting should remove submit button' do
    submit_feedback(@spv)
    assert_text "Bestätigt am #{I18n.l(@spv.commited_at.to_date)} durch #{@spv.commited_by.full_name}"
  end

  test 'you should be able to add hours on run' do
    fill_in_required_feedback_fields
    fill_in 'Stunden', with: 10
    check 'Ich verzichte auf die Auszahlung von Spesen.'
    click_on 'Bestätigen', match: :first
    @spv.reload
    assert_equal Hour.last.hours, 10
    assert_equal Hour.last.hourable, @spv.missions.last
  end

  test 'iban and bank has to be filled' do
    fill_in_required_feedback_fields
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
    fill_in_required_feedback_fields
    fill_in 'Kommentare', with: 'nothing'
    check 'Ich wünsche ein Gespräch mit meiner/meinem Freiwilligenverantwortlichen.'
    fill_in 'Stunden', with: 33
    uncheck 'Ich verzichte auf die Auszahlung von Spesen.'
    fill_in 'IBAN', with: 'CH59 2012 0767 0052 0024 0'
    fill_in 'Name der Bank', with: 'Bank'
    click_on 'Bestätigen'
    @spv.reload
    assert_equal @spv.volunteer.slice(:iban, :bank, :waive),
      { iban: 'CH59 2012 0767 0052 0024 0', bank: 'Bank', waive: false }.stringify_keys
    assert_equal @spv.semester_feedbacks.last.slice(:goals, :achievements, :future, :comments, :conversation),
      { goals: 'being on time', achievements: 'everything', future: 'continue', comments: 'nothing', conversation: true }.stringify_keys
    assert_equal Hour.last.hours, 33
    assert_equal Hour.last.hourable, @spv.missions.first
  end

  test 'truncate_modal_shows_all_text' do
    goals = FFaker::Lorem.paragraph(20)
    achievements = FFaker::Lorem.paragraph(20)
    future = FFaker::Lorem.paragraph(20)
    comments = FFaker::Lorem.paragraph(20)

    @superadmin = create :user
    login_as @superadmin
    visit review_semester_semester_process_volunteer_path(@spv)

    fill_in 'Was waren die wichtigsten Inhalte (oder Ziele) Ihres Einsatzes in den letzten Monaten?', with: goals
    fill_in 'Was konnte in den letzten Monaten erreicht werden?', with: achievements
    fill_in 'Soll der Einsatz weiterlaufen und wenn ja, mit welchen Inhalten (Zielen)?', with: future
    fill_in 'Kommentare', with: comments

    # submit feedback without revisiting review form
    check 'Ich verzichte auf die Auszahlung von Spesen.'
    click_on 'Bestätigen', match: :first
    @spv.reload
    visit semester_process_volunteers_path(semester: Semester.to_s(@spv.semester))

    page.find('td', text: goals.truncate(300)).click
    assert page.has_text? goals
    click_button 'Schliessen'

    page.find('td', text: achievements.truncate(300)).click
    assert page.has_text? achievements
    click_button 'Schliessen'

    page.find('td', text: future.truncate(300)).click
    assert page.has_text? future
    click_button 'Schliessen'

    page.find('td', text: comments.truncate(300)).click
    assert page.has_text? comments
    click_button 'Schliessen'
  end
end
