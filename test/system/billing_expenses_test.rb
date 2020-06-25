require 'application_system_test_case'

class BillingExpensesTest < ApplicationSystemTestCase
  def setup
    @base_date = Time.zone.now.beginning_of_year
    @test_run_now = @base_date.change(month: 5, day: 27, hour: 12, minute: 0, second: 0)
    @prev_semester_day = @base_date.advance(months: -2).change(hour: 18, minute: 10)

    # create setup one year earlyer
    travel_to @base_date.advance(years: -3)
    superadmin = create :user
    @volunteer1 = create :volunteer, bank: 'UBS'
    @assignment1 = create :assignment, volunteer: @volunteer1
    group_assignment1 = create :group_assignment, volunteer: @volunteer1
    @volunteer2 = create :volunteer
    assignment2 = create :assignment, volunteer: @volunteer2
    @volunteer3 = create :volunteer, iban: nil
    assignment3 = create :assignment, volunteer: @volunteer3
    @volunteer4 = create :volunteer
    group_assignment4 = create :group_assignment, volunteer: @volunteer4

    # create some more earlyer semester allready billed hours as unrelated history
    current_create_time = @base_date.advance(years: -1).change(month: 2)
    travel_to current_create_time
    hour = create :hour, hourable: create(:assignment), hours: 10, meeting_date: current_create_time
    create :billing_expense, volunteer: hour.hourable.volunteer, hours: [hour]
    hour = create :hour, hourable: create(:assignment), hours: 10, meeting_date: current_create_time
    create :billing_expense, volunteer: hour.hourable.volunteer, hours: [hour]
    hour = create :hour, hourable: create(:assignment), hours: 10, meeting_date: current_create_time
    create :billing_expense, volunteer: hour.hourable.volunteer, hours: [hour]
    hour = create :hour, hourable: create(:group_assignment), hours: 10, meeting_date: current_create_time
    create :billing_expense, volunteer: hour.hourable.volunteer, hours: [hour]
    current_create_time = @base_date.advance(years: -1, months: -4)
    travel_to current_create_time
    hour = create :hour, hourable: create(:assignment), hours: 10, meeting_date: current_create_time
    create :billing_expense, volunteer: hour.hourable.volunteer, hours: [hour]
    hour = create :hour, hourable: create(:assignment), hours: 10, meeting_date: current_create_time
    create :billing_expense, volunteer: hour.hourable.volunteer, hours: [hour]
    hour = create :hour, hourable: create(:assignment), hours: 10, meeting_date: current_create_time
    create :billing_expense, volunteer: hour.hourable.volunteer, hours: [hour]
    hour = create :hour, hourable: create(:group_assignment), hours: 10, meeting_date: current_create_time
    create :billing_expense, volunteer: hour.hourable.volunteer, hours: [hour]

    travel_to @prev_semester_day.advance(days: 1) # 2. november - so in last semester
    billed_hour4 = create :hour, volunteer: @volunteer4, hourable: group_assignment4.group_offer, hours: 5.5, meeting_date: @prev_semester_day

    # create hours within the relevant semester
    current_create_time = @base_date.advance(months: rand(-1..3), days: rand(1..22))
    travel_to current_create_time
    create :hour, volunteer: @volunteer1, hourable: @assignment1, hours: 2.5, meeting_date: current_create_time.advance(days: -1)
    current_create_time = @base_date.advance(months: rand(-1..3), days: rand(1..22))
    travel_to current_create_time
    billed_hour1 = create :hour, volunteer: @volunteer1, hourable: @assignment1, hours: 3.5, meeting_date: current_create_time.advance(days: -1)
    current_create_time = @base_date.advance(months: rand(-1..3), days: rand(1..22))
    travel_to current_create_time
    create :hour, hourable: group_assignment1.group_offer, volunteer: @volunteer1, hours: 35, meeting_date: current_create_time.advance(days: -1)
    current_create_time = @base_date.advance(months: rand(-1..3), days: rand(1..22))
    travel_to current_create_time
    create :hour, volunteer: @volunteer2, hourable: assignment2, hours: 4.5, meeting_date: current_create_time.advance(days: -1)
    current_create_time = @base_date.advance(months: rand(-1..3), days: rand(1..22))
    travel_to current_create_time
    create :hour, volunteer: @volunteer3, hourable: assignment3, hours: 2.5, meeting_date: current_create_time.advance(days: -1)

    # create first billing expense two hours earlyer than the test
    travel_to @test_run_now.advance(hours: -2)
    @billing_expense1 = create :billing_expense, volunteer: @volunteer1, hours: [billed_hour1]

    # create first billing expense one hour earlyer than the test
    travel_to @test_run_now.advance(hours: -1)
    @billing_expense4 = create :billing_expense, volunteer: @volunteer4, hours: [billed_hour4]

    # run test at noon
    travel_to @test_run_now
    login_as superadmin
  end

  test 'index shows existing billing expenses' do
    visit billing_expenses_path

    assert_text 'Spesenformulare'
    assert_link 'Herunterladen', count: 1
    assert_text "#{@volunteer1} UBS, #{@volunteer1.iban} 3.5 Stunden Fr. 50.00"
    refute_text @volunteer2, wait: 0
    refute_text @volunteer3, wait: 0
    refute_text @volunteer4, wait: 0

    click_link "Semester: 1. Semester #{@base_date.year}"
    click_link "2. Semester #{@base_date.year - 1}"

    assert_text "#{@volunteer4} #{@volunteer4.iban} 5.5 Stunden Fr. 50.00"
    refute_text @volunteer1, wait: 0
    click_link "Semester: 2. Semester #{@base_date.year - 1}"
    click_link 'Alle'

    assert_text @volunteer1.full_name
    assert_text @volunteer4.full_name
  end

  test 'superadmin_can_create_billing_expenses_for_unbilled_hours' do
    visit billing_expenses_path
    click_link 'Spesenformulare erfassen'

    assert_text "#{@volunteer1} UBS, #{@volunteer1.iban} 37.5 Stunden Fr. 100.00", normalize_ws: true
    assert_text "#{@volunteer2} #{@volunteer2.iban} 4.5 Stunden Fr. 50.00", normalize_ws: true
    assert_text "#{@volunteer3} Keine IBAN angegeben 2.5 Stunden Fr. 50.00", normalize_ws: true
    refute_text @volunteer4, wait: 0

    check 'table-row-select-all'

    assert_checked_field 'selected_volunteers[]', count: 2
    assert_unchecked_field 'selected_volunteers[]', count: 1, disabled: true

    page.accept_confirm do
      click_button 'Selektierte Spesenformulare erstellen'
    end

    assert_text 'Spesenformulare wurden erfolgreich erstellt.'
    assert_text "#{@volunteer1} UBS, #{@volunteer1.iban} 37.5 Stunden Fr. 100.00"
    assert_text "#{@volunteer2} #{@volunteer2.iban} 4.5 Stunden Fr. 50.00"
    refute_text @volunteer3, wait: 0

    create :hour, volunteer: @volunteer1, hourable: @assignment1, hours: 1.5, meeting_date: @base_date
    click_link 'Spesenformulare erfassen'
    assert_text "#{@volunteer3} Keine IBAN angegeben 2.5 Stunden Fr. 50.00"
    refute_text @volunteer1, wait: 0
    refute_text @volunteer2, wait: 0
    refute_text @volunteer4, wait: 0
  end

  test 'new_billing_expense_respects_the_semester_filter' do
    travel_to @base_date.advance(years: -3)
    volunteer1 = create :volunteer
    volunteer2 = create :volunteer, iban: 'pick_out_volunteer'
    volunteer3 = create :volunteer

    travel_to @prev_semester_day.advance(days: 1)
    create :hour, volunteer: volunteer1, hours: 10, meeting_date: @prev_semester_day
    create :hour, volunteer: volunteer1, hours: 16, meeting_date: @prev_semester_day.advance(months: -1)

    travel_to @base_date.change(month: 2, day: 2)
    create :hour, volunteer: volunteer2, hours: 26, meeting_date: @base_date.change(month: 2, day: 1)
    create :hour, volunteer: volunteer2, hours: 15, meeting_date: @prev_semester_day

    travel_to @base_date.change(month: 4, day: 2)
    create :hour, volunteer: volunteer3, hours: 1, meeting_date: @base_date.change(month: 2, day: 1)
    create :hour, volunteer: volunteer3, hours: 2, meeting_date: @base_date.change(month: 4, day: 1)

    travel_to @test_run_now
    visit billing_expenses_path

    click_link 'Spesenformulare erfassen'
    assert_text "#{volunteer2} #{volunteer2.iban} 26 Stunden Fr. 100.00 1. Semester #{@base_date.year}", normalize_ws: true
    assert_text "#{volunteer3} #{volunteer3.iban} 3 Stunden Fr. 50.00 1. Semester #{@base_date.year}", normalize_ws: true
    refute_text volunteer1, wait: 0

    visit billing_expenses_path

    click_link "Semester: 1. Semester #{@base_date.year}"
    click_link "2. Semester #{@base_date.year - 1}"
    click_link 'Spesenformulare erfassen'
    assert_text "#{volunteer1} #{volunteer1.iban} 26 Stunden Fr. 100.00 2. Semester #{@base_date.year - 1}"
    assert_text "#{volunteer2} #{volunteer2.iban} 15 Stunden Fr. 50.00 2. Semester #{@base_date.year - 1}"
    refute_text volunteer3, wait: 0
  end

  test 'creating_a_billing_expense_should_respect_semester_filter' do
    volunteer = create :volunteer
    travel_to @prev_semester_day.advance(days: 1)
    create :hour, volunteer: volunteer, hours: 26, meeting_date: @prev_semester_day
    travel_to @base_date.change(month: 2, day: 2)
    create :hour, volunteer: volunteer, hours: 16, meeting_date: @base_date.change(month: 2, day: 1)

    travel_to @test_run_now

    # creating billing_expense for hours in the current semester
    visit billing_expenses_path

    click_link 'Spesenformulare erfassen'

    within "##{dom_id(volunteer)}" do
      check 'selected_volunteers[]'
    end

    assert_checked_field 'selected_volunteers[]', count: 1
    page.accept_confirm do
      click_button 'Selektierte Spesenformulare erstellen'
    end

    assert_text "#{volunteer} #{volunteer.iban} 16 Stunden Fr. 50.00 1. Semester #{@base_date.year}", normalize_ws: true
    # creating billing_expense for hours in 2. Semester 2017
    visit billing_expenses_path
    click_link "Semester: 1. Semester #{@base_date.year}"
    click_link "2. Semester #{@base_date.year - 1}"
    click_link 'Spesenformulare erfassen'

    within "##{dom_id(volunteer)}" do
      check 'selected_volunteers[]'
    end

    assert_checked_field 'selected_volunteers[]', count: 1
    page.accept_confirm do
      click_button 'Selektierte Spesenformulare erstellen'
    end

    click_link "Semester: 1. Semester #{@base_date.year}"
    click_link 'Alle'
    assert_text "#{volunteer} #{volunteer.iban} 26 Stunden Fr. 100.00 2. Semester #{@base_date.year - 1}", normalize_ws: true
  end

  test 'volunteer profile shows only billing expenses for this volunteer' do
    login_as @volunteer1.user
    visit volunteer_path(@volunteer1)
    click_link 'Spesen', match: :first

    assert_text "Spesenformulare für #{@volunteer1}"
    assert_text "UBS, #{@volunteer1.iban} 3.5 Stunden Fr. 50.00"
    refute_text @volunteer4, wait: 0

    assert_link 'Zurück', href: volunteer_path(@volunteer1)
  end

  test 'created billing expenses has needed fields' do
    @billing_expense4.destroy

    visit billing_expenses_path
    click_link 'Anzeigen'

    assert_text "Spesenauszahlung an #{@volunteer1}"
    assert_text 'Kostenstelle 3120000', normalize_ws: true
    assert_text 'Konto 317000153', normalize_ws: true
    assert_text 'zu überweisender Betrag Fr. 50.00', normalize_ws: true
    assert_text "Nachname #{@volunteer1.contact.last_name}", normalize_ws: true
    assert_text "Vorname #{@volunteer1.contact.first_name}", normalize_ws: true
    assert_text "Strasse #{@volunteer1.contact.street}", normalize_ws: true
    assert_text "PLZ / Ort #{@volunteer1.contact.postal_code}, #{@volunteer1.contact.city}", normalize_ws: true
    assert_text "Name der Bank / IBAN UBS, #{@volunteer1.iban}", normalize_ws: true
    assert_text "Zürich, #{I18n.l @billing_expense1.created_at.to_date, format: :long}", normalize_ws: true
  end

  test 'delete billing expenses' do
    @billing_expense4.destroy

    visit billing_expenses_path

    assert_text @billing_expense1.volunteer

    page.accept_confirm do
      click_link 'Löschen'
    end

    assert_text 'Spesenformular wurde erfolgreich gelöscht.'
    refute_text @billing_expense1.volunteer, wait: 0
  end

  test 'download_single_billing_expense' do
    use_rack_driver

    visit billing_expenses_path
    click_on 'Herunterladen', match: :first
    pdf = load_pdf(page.body)

    assert_equal 1, pdf.page_count
    assert_includes pdf.pages.first.text, @volunteer1.contact.last_name
    assert_includes pdf.pages.first.text, @volunteer1.contact.first_name
  end

  # buggy test, commented out for now as it is not possible to test it locally
  # test 'download_multiple_billing_expenses' do
  #   use_rack_driver

  #   visit billing_expenses_path
  #   click_link "Semester: 1. Semester #{@base_date.year}"
  #   click_link 'Alle'

  #   page.all('input[type="checkbox"]').each(&:click)
  #   click_on 'Auswahl herunterladen'
  #   pdf = load_pdf(page.body)

  #   assert_equal 4, pdf.page_count
  #   assert_includes pdf.pages[1].text, "Spesenauszahlung an #{@volunteer1}"
  #   assert_includes pdf.pages[0].text, "Spesenauszahlung an #{@volunteer4}"
  # end

  test 'amount is editable' do
    travel_to @base_date.advance(years: -3)
    volunteer = create :volunteer
    travel_to @test_run_now
    billing_expense = create :billing_expense, volunteer: volunteer, hours: [
      create(:hour, volunteer: volunteer, hours: 1),
      create(:hour, volunteer: volunteer, hours: 2),
      create(:hour, volunteer: volunteer, hours: 3)
    ]
    assert_equal billing_expense.final_amount, 50

    visit billing_expense_path billing_expense

    first('.overwritten_amount .field_label').click
    first('.overwritten_amount .field_input').fill_in(with: '100')
    first('.overwritten_amount').click

    assert page.has_text? 'Fr. 100'
    assert_equal billing_expense.reload.final_amount, 100
  end
end
