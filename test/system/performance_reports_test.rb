require 'application_system_test_case'
require 'utility/performance_report_generator'

class PerformanceReportsTest < ApplicationSystemTestCase
  include PerformanceReportGenerator

  setup do
    @user = create :user
    login_as @user
    visit performance_reports_path
  end

  test 'create new report' do
    two_years_ago = Time.zone.now.years_ago(2).year
    first(:link, 'Neuen Report erstellen').click
    click_link two_years_ago.to_s
    click_button 'Kennzahlen Report erfassen'
    assert page.has_text? 'Kennzahlen Report wurde erfolgreich erstellt.'
    assert page.has_text? "Kennzahlen des Kalenderjahrs #{two_years_ago}"
  end

  test 'performance report data displayed' do
    main_setup_entities
    report_id, this_year_report = PerformanceReport.create!(
      user: @user, period_start: @today.beginning_of_year, period_end: @today.end_of_year
    ).slice(:id, :report_content).values

    visit performance_report_path(report_id)
    volunteers, clients, assignments, group_offers = this_year_report.values_at('volunteers',
      'clients', 'assignments', 'group_offers')

    # Volunteers section
    column_order = ['zurich', 'not_zurich', 'internal', 'external', 'all']
    assert page.has_text? 'Erstellt ' + row_numbers(volunteers, column_order, :created)
    assert page.has_text? 'Inaktiv ' + row_numbers(volunteers, column_order, :inactive)
    assert page.has_text? 'Beendet ' + row_numbers(volunteers, column_order, :resigned)
    assert page.has_text? 'Gesammt ' + row_numbers(volunteers, column_order, :total)

    assert page.has_text? 'Nur in Tandem aktiv ' +
      row_numbers(volunteers, column_order, :only_assignment_active)
    assert page.has_text? 'Mit aktivem Gruppeneinsatz ' +
      row_numbers(volunteers, column_order, :active_group_assignment)
    assert page.has_text? 'Nur in Gruppenangebot aktiv ' +
      row_numbers(volunteers, column_order, :only_group_active)
    assert page.has_text? 'Aktiv in Gruppeneinsatz und Tandem ' +
      row_numbers(volunteers, column_order, :active_both)
    assert page.has_text? 'Total mit aktivem Tandem ' +
      row_numbers(volunteers, column_order, :active_assignment)
    assert page.has_text? 'Total Akiv ' + row_numbers(volunteers, column_order, :active_total)

    assert page.has_text? 'Tandem-Stundenberichte ' +
      row_numbers(volunteers, column_order, :assignment_hour_records)
    assert page.has_text? 'Tandem-Stunden ' +
      row_numbers(volunteers, column_order, :assignment_hours, hours: true)
    assert page.has_text? 'Gruppenangebots-Stundenberichte ' +
      row_numbers(volunteers, column_order, :group_offer_hour_records)
    assert page.has_text? 'Gruppenangebots-Stunden ' +
      row_numbers(volunteers, column_order, :group_offer_hours, hours: true)
    assert page.has_text? 'Eingereichte Stundenberichte ' +
      row_numbers(volunteers, column_order, :total_hour_records)
    assert page.has_text? 'Stunden total ' + row_numbers(volunteers, column_order, :total_hours, hours: true)

    assert page.has_text? 'Tandem-Feedbacks ' +
      row_numbers(volunteers, column_order, :assignment_feedbacks)
    assert page.has_text? 'Gruppenangebots-Feedbacks ' +
      row_numbers(volunteers, column_order, :group_offer_feedbacks)
    assert page.has_text? 'Total Feedbacks ' +
      row_numbers(volunteers, column_order, :total_feedbacks)

    assert page.has_text? 'Tandem-Probezeit-Feedbacks ' +
      row_numbers(volunteers, column_order, :assignment_trial_feedbacks)
    assert page.has_text? 'Gruppenangebots-Probezeit-Feedbacks ' +
      row_numbers(volunteers, column_order, :group_offer_trial_feedbacks)
    assert page.has_text? 'Total Probezeit-Feedbacks ' +
      row_numbers(volunteers, column_order, :total_trial_feedbacks)

    assert page.has_text? 'Teilnehmende Einführungsveranstaltungen ' +
      row_numbers(volunteers, column_order, :intro_course)
    assert page.has_text? 'Teilnehmende Weiterbildungen ' +
      row_numbers(volunteers, column_order, :professional_training)
    assert page.has_text? 'Teilnehmende Fachveranstaltungen ' +
      row_numbers(volunteers, column_order, :professional_event)
    assert page.has_text? 'Teilnehmende Erfahrungsaustausch/Themenabende ' +
      row_numbers(volunteers, column_order, :theme_exchange)
    assert page.has_text? 'Teilnehmende Freiwilligenanlässe ' +
      row_numbers(volunteers, column_order, :volunteering)
    assert page.has_text? 'Teilnehmende Treffen Deutschkursleitende ' +
      row_numbers(volunteers, column_order, :german_class_managers)
    assert page.has_text? 'Total Teilnehmende Veranstaltungen ' +
      row_numbers(volunteers, column_order, :total_events)

    # Clients section
    column_order = ['zurich', 'not_zurich', 'all']
    assert page.has_text? 'Erstellt ' + row_numbers(clients, column_order, :created)
    assert page.has_text? 'Inaktiv ' + row_numbers(clients, column_order, :inactive)
    assert page.has_text? 'Beendet ' + row_numbers(clients, column_order, :resigned)
    assert page.has_text? 'Gesammt ' + row_numbers(clients, column_order, :total)
    assert page.has_text? 'Total mit aktivem Tandem ' +
      row_numbers(clients, column_order, :active_assignment)

    # Assignment section
    column_order = ['zurich', 'not_zurich', 'internal', 'external', 'all']
    assert page.has_text? 'Erstellt ' + row_numbers(assignments, column_order, :created)
    assert page.has_text? 'Begonnen ' + row_numbers(assignments, column_order, :started)
    assert page.has_text? 'Aktiv ' + row_numbers(assignments, column_order, :active)
    assert page.has_text? 'Beendet ' + row_numbers(assignments, column_order, :ended)
    assert page.has_text? 'Alle ' + row_numbers(assignments, column_order, :all)

    assert page.has_text? 'Anzahl Stundenrapporte ' +
      row_numbers(assignments, column_order, :hour_report_count)
    assert page.has_text? 'Stunden ' + row_numbers(assignments, column_order, :hours, hours: true)
    assert page.has_text? 'Anzahl Feedbacks ' +
      row_numbers(assignments, column_order, :feedback_count)
    assert page.has_text? 'Einführungskurse ' +
      row_numbers(assignments, column_order, :first_instruction_lessons)
    assert page.has_text? 'Probezeiten abgeschlossen ' +
      row_numbers(assignments, column_order, :probations_ended)
    assert page.has_text? 'Anzahl Probezeitfeedbacks ' +
      row_numbers(assignments, column_order, :trial_feedback_count)

    assert page.has_text? 'Standortgespräche ' +
      row_numbers(assignments, column_order, :performance_appraisal_reviews)
    assert page.has_text? 'Hausbesuche ' + row_numbers(assignments, column_order, :home_visits)
    assert page.has_text? 'Fortschrittsmeetings ' +
      row_numbers(assignments, column_order, :progress_meetings)
    assert page.has_text? 'Beendigung bestätigt ' +
      row_numbers(assignments, column_order, :termination_submitted)
    assert page.has_text? 'Beendigung quittiert ' +
      row_numbers(assignments, column_order, :termination_verified)

    # Group Offer section
    column_order = ['internal', 'external', 'all']
    assert page.has_text? 'Erstellt ' + row_numbers(group_offers, column_order, :created)
    assert page.has_text? 'Beendet ' + row_numbers(group_offers, column_order, :ended)
    assert page.has_text? 'Alle ' + row_numbers(group_offers, column_order, :all)

    assert page.has_text? 'Mit neu erstellten Gruppeneinsätzen ' +
      row_numbers(group_offers, column_order, :created_assignments)
    assert page.has_text? 'Mit gestarteten Gruppeneinsätzen ' +
      row_numbers(group_offers, column_order, :started_assignments)
    assert page.has_text? 'Mit beendeten Gruppeneinsätzen ' +
      row_numbers(group_offers, column_order, :ended_assignments)
    assert page.has_text? 'Mit aktiven Gruppeneinsätzen ' +
      row_numbers(group_offers, column_order, :active_assignments)

    assert page.has_text? 'Anzahl erstellte Gruppeneinsätze ' +
      row_numbers(group_offers, column_order, :total_created_assignments)
    assert page.has_text? 'Anzahl gestartete Gruppeneinsätze ' +
      row_numbers(group_offers, column_order, :total_started_assignments)
    assert page.has_text? 'Anzahl aktive Gruppeneinsätze ' +
      row_numbers(group_offers, column_order, :total_active_assignments)
    assert page.has_text? 'Anzahl Beendeter Gruppeneinsätze ' +
      row_numbers(group_offers, column_order, :total_ended_assignments)
    assert page.has_text? 'Gruppeneinsätze Total ' +
      row_numbers(group_offers, column_order, :total_assignments)

    assert page.has_text? 'Anzahl Stundenrapporte ' +
      row_numbers(group_offers, column_order, :hour_report_count)
    assert page.has_text? 'Stunden ' + row_numbers(group_offers, column_order, :hours, hours: true)
    assert page.has_text? 'Anzahl Feedbacks ' +
      row_numbers(group_offers, column_order, :feedback_count)
  end

  def row_numbers(entity, column_order, key, hours: nil)
    if hours
      entity.values_at(*column_order).map { |val| '%g' % ('%.1f' % val[key.to_s]) }.join(' ')
    else
      entity.values_at(*column_order).map { |val| val[key.to_s] }.join(' ')
    end
  end
end
