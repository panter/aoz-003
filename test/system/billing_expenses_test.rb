require 'application_system_test_case'

class BillingExpensesTest < ApplicationSystemTestCase
  def setup
    superadmin = create :user
    @date = Time.zone.parse('2018-01-01')

    @volunteer1 = create :volunteer, bank: 'UBS'
    @assignment1 = create :assignment, volunteer: @volunteer1
    create :hour, volunteer: @volunteer1, hourable: @assignment1, hours: 2.5, meeting_date: @date
    billed_hour1 = create :hour, volunteer: @volunteer1, hourable: @assignment1,
      hours: 3.5, meeting_date: @date
    @billing_expense1 = create :billing_expense, volunteer: @volunteer1, hours: [billed_hour1],
      created_at: 2.hours.ago
    group_assignment1 = create :group_assignment, volunteer: @volunteer1
    create :hour, hourable: group_assignment1.group_offer, volunteer: @volunteer1,
      hours: 35, meeting_date: @date

    @volunteer2 = create :volunteer
    assignment2 = create :assignment, volunteer: @volunteer2
    create :hour, volunteer: @volunteer2, hourable: assignment2,
      hours: 4.5, meeting_date: @date

    @volunteer3 = create :volunteer, iban: nil
    assignment3 = create :assignment, volunteer: @volunteer3
    create :hour, volunteer: @volunteer3, hourable: assignment3,
      hours: 2.5, meeting_date: @date

    @volunteer4 = create :volunteer
    group_assignment4 = create :group_assignment, volunteer: @volunteer4
    billed_hour4 = create :hour, volunteer: @volunteer4,
      hourable: group_assignment4.group_offer,
      hours: 5.5, meeting_date: Time.zone.parse('2017-11-01')
    @billing_expense4 = create :billing_expense, volunteer: @volunteer4, hours: [billed_hour4],
      created_at: 1.hour.ago

    login_as superadmin
  end

  test 'index shows existing billing expenses' do
    visit billing_expenses_path

    assert_text 'Spesenformulare'
    assert_link 'Herunterladen', count: 1

    assert_text "#{@volunteer1} UBS, #{@volunteer1.iban} 3.5 Stunden Fr. 50.00"
    refute_text @volunteer2
    refute_text @volunteer3
    refute_text @volunteer4

    click_link 'Semester: 1. Semester 2018'
    click_link '2. Semester 2017'

    assert_text "#{@volunteer4} #{@volunteer4.iban} 5.5 Stunden Fr. 50.00"
    refute_text @volunteer1

    click_link 'Semester: 2. Semester 2017'
    click_link 'Alle'

    assert_link 'Herunterladen', count: 2
    assert_text @volunteer1
    assert_text @volunteer4
  end

  test 'superadmin can create billing expenses for unbilled hours' do
    visit billing_expenses_path
    click_link 'Spesenformulare erstellen'

    assert_text "#{@volunteer1} UBS, #{@volunteer1.iban} 37.5 Stunden Fr. 100.00"
    assert_text "#{@volunteer2} #{@volunteer2.iban} 4.5 Stunden Fr. 50.00"
    assert_text "#{@volunteer3} Keine IBAN angegeben 2.5 Stunden Fr. 50.00"
    refute_text @volunteer4

    check 'table-row-select-all'

    assert_checked_field 'selected_volunteers[]', count: 2
    assert_unchecked_field 'selected_volunteers[]', count: 1, disabled: true

    page.accept_confirm do
      click_button 'Spesenformulare erstellen'
    end

    assert_text 'Spesenformulare wurden erfolgreich erstellt.'
    assert_text "#{@volunteer1} UBS, #{@volunteer1.iban} 37.5 Stunden Fr. 100.00"
    assert_text "#{@volunteer2} #{@volunteer2.iban} 4.5 Stunden Fr. 50.00"
    refute_text @volunteer3

    create :hour, volunteer: @volunteer1, hourable: @assignment1, hours: 1.5, meeting_date: @date
    click_link 'Spesenformulare erstellen'

    assert_text "#{@volunteer1} UBS, #{@volunteer1.iban} 1.5 Stunden Fr. 50.00"
    refute_text @volunteer2
    assert_text "#{@volunteer3} Keine IBAN angegeben 2.5 Stunden Fr. 50.00"
    refute_text @volunteer4
  end

  test 'new_billing_expense_respects_the_period_filter' do
    volunteer1 = create :volunteer
    create :hour, volunteer: volunteer1, hours: 10, meeting_date: Time.zone.parse('2017-11-01')
    create :hour, volunteer: volunteer1, hours: 16, meeting_date: Time.zone.parse('2017-10-01')

    volunteer2 = create :volunteer, iban: 'pick_out_volunteer'
    create :hour, volunteer: volunteer2, hours: 26, meeting_date: Time.zone.parse('2018-02-01')
    create :hour, volunteer: volunteer2, hours: 15, meeting_date: Time.zone.parse('2017-11-01')

    volunteer3 = create :volunteer
    create :hour, volunteer: volunteer3, hours: 1, meeting_date: Time.zone.parse('2018-02-01')
    create :hour, volunteer: volunteer3, hours: 2, meeting_date: Time.zone.parse('2018-04-01')

    visit billing_expenses_path

    click_link 'Spesenformulare erstellen'
    assert_text "#{volunteer2} #{volunteer2.iban} 26 Stunden Fr. 100.00 1. Semester 2018"
    assert_text "#{volunteer3} #{volunteer3.iban} 3 Stunden Fr. 50.00 1. Semester 2018"
    refute_text volunteer1

    visit billing_expenses_path

    click_link 'Semester: 1. Semester 2018'
    click_link '2. Semester 2017'
    click_link 'Spesenformulare erstellen'
    assert_text "#{volunteer1} #{volunteer1.iban} 26 Stunden Fr. 100.00 2. Semester 2017"
    assert_text "#{volunteer2} #{volunteer2.iban} 15 Stunden Fr. 50.00 2. Semester 2017"
    refute_text volunteer3

    visit billing_expenses_path

    click_link 'Semester: 1. Semester 2018'
    click_link 'Alle'
    click_link 'Spesenformulare erstellen'
    assert_text "#{volunteer1} #{volunteer1.iban} 26 Stunden Fr. 100.00 2. Semester 2017"
    assert_text "#{volunteer2} #{volunteer2.iban} 41 Stunden Fr. 100.00" \
      ' 2. Semester 2017 - 1. Semester 2018'
    assert_text "#{volunteer3} #{volunteer3.iban} 3 Stunden Fr. 50.00 1. Semester 2018"
  end

  test 'creating_a_billing_expense_should_respect_period_filter' do
    volunteer = create :volunteer
    create :hour, volunteer: volunteer, hours: 26, meeting_date: Time.zone.parse('2017-11-01')
    create :hour, volunteer: volunteer, hours: 16, meeting_date: Time.zone.parse('2018-02-01')

    # creating billing_expense for hours in the current period
    visit billing_expenses_path

    click_link 'Spesenformulare erstellen'

    within "##{dom_id(volunteer)}" do
      check 'selected_volunteers[]'
    end

    assert_checked_field 'selected_volunteers[]', count: 1
    page.accept_confirm do
      click_button 'Spesenformulare erstellen'
    end

    assert_text "#{volunteer} #{volunteer.iban} 16 Stunden Fr. 50.00 1. Semester 2018"

    # creating billing_expense for the all remaining hours
    visit billing_expenses_path
    click_link 'Semester: 1. Semester 2018'
    click_link 'Alle'
    click_link 'Spesenformulare erstellen'

    within "##{dom_id(volunteer)}" do
      check 'selected_volunteers[]'
    end

    assert_checked_field 'selected_volunteers[]', count: 1
    page.accept_confirm do
      click_button 'Spesenformulare erstellen'
    end

    click_link 'Semester: 1. Semester 2018'
    click_link 'Alle'
    assert_text "#{volunteer} #{volunteer.iban} 26 Stunden Fr. 100.00 2. Semester 2017"

    # creating billing_expense for all hours in multiple periods
    volunteer = create :volunteer
    create :hour, volunteer: volunteer, hours: 26, meeting_date: Time.zone.parse('2017-11-01')
    create :hour, volunteer: volunteer, hours: 16, meeting_date: Time.zone.parse('2018-02-01')

    visit billing_expenses_path
    click_link 'Semester: 1. Semester 2018'
    click_link 'Alle'
    click_link 'Spesenformulare erstellen'

    within "##{dom_id(volunteer)}" do
      check 'selected_volunteers[]'
    end

    assert_checked_field 'selected_volunteers[]', count: 1
    page.accept_confirm do
      click_button 'Spesenformulare erstellen'
    end

    click_link 'Semester: 1. Semester 2018'
    click_link 'Alle'
    assert_text "#{volunteer} #{volunteer.iban} 42 Stunden Fr. 100.00"\
      ' 2. Semester 2017 - 1. Semester 2018'
  end

  test 'volunteer profile shows only billing expenses for this volunteer' do
    login_as @volunteer1.user
    visit volunteer_path(@volunteer1)
    click_link 'Spesen', match: :first

    assert_text "Spesenformulare für #{@volunteer1}"
    assert_text "UBS, #{@volunteer1.iban} 3.5 Stunden Fr. 50.00"
    refute_text @volunteer4

    assert_link 'Zurück', href: volunteer_path(@volunteer1)
  end

  test 'created billing expenses has needed fields' do
    @billing_expense4.destroy

    visit billing_expenses_path
    click_link 'Anzeigen'

    assert_text "Spesenauszahlung an #{@volunteer1}"
    assert_text 'Kostenstelle 4182'
    assert_text 'Konto 4621'
    assert_text 'zu überweisender Betrag Fr. 50.00'
    assert_text "Nachname #{@volunteer1.contact.last_name}"
    assert_text "Vorname #{@volunteer1.contact.first_name}"
    assert_text "Strasse #{@volunteer1.contact.street}"
    assert_text "PLZ / Ort #{@volunteer1.contact.postal_code}, #{@volunteer1.contact.city}"
    assert_text "Name der Bank / IBAN UBS, #{@volunteer1.iban}"
    assert_text "Zürich, #{I18n.l @billing_expense1.created_at.to_date, format: :long}"
  end

  test 'delete billing expenses' do
    @billing_expense4.destroy

    visit billing_expenses_path

    assert_text @billing_expense1.volunteer

    page.accept_confirm do
      click_link 'Löschen'
    end

    assert_text 'Spesenformular wurde erfolgreich gelöscht.'
    refute_text @billing_expense1.volunteer
  end

  test 'download_single_billing_expense' do
    use_rack_driver

    visit billing_expenses_path
    click_on 'Herunterladen', match: :first
    pdf = load_pdf(page.body)

    assert_equal 1, pdf.page_count
    assert_includes pdf.pages.first.text, "Spesenauszahlung an #{@volunteer1}"
  end

  test 'download_multiple_billing_expenses' do
    use_rack_driver

    visit billing_expenses_path
    click_link 'Semester: 1. Semester 2018'
    click_link 'Alle'

    page.all('input[type="checkbox"]').each(&:click)
    click_on 'Auswahl herunterladen'
    pdf = load_pdf(page.body)

    assert_equal 2, pdf.page_count
    assert_includes pdf.pages[1].text, "Spesenauszahlung an #{@volunteer1}"
    assert_includes pdf.pages[0].text, "Spesenauszahlung an #{@volunteer4}"
  end

  test 'amount is editable' do
    volunteer = create :volunteer
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
