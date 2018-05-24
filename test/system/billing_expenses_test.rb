require 'application_system_test_case'

class BillingExpensesTest < ApplicationSystemTestCase
  def setup
    superadmin = create :user
    date = '2018-01-01'.to_time

    @volunteer1 = create :volunteer, bank: 'UBS'
    @assignment1 = create :assignment, volunteer: @volunteer1
    create :hour, volunteer: @volunteer1, hourable: @assignment1, hours: 2.5
    billed_hour1 = create :hour, volunteer: @volunteer1, hourable: @assignment1,
      hours: 3.5, meeting_date: date
    @billing_expense1 = create :billing_expense, volunteer: @volunteer1, hours: [billed_hour1],
      created_at: 2.hours.ago
    group_assignment1 = create :group_assignment, volunteer: @volunteer1
    create :hour, hourable: group_assignment1.group_offer, volunteer: @volunteer1,
      hours: 35, meeting_date: date

    @volunteer2 = create :volunteer
    assignment2 = create :assignment, volunteer: @volunteer2
    create :hour, volunteer: @volunteer2, hourable: assignment2,
      hours: 4.5, meeting_date: date

    @volunteer3 = create :volunteer, iban: nil
    assignment3 = create :assignment, volunteer: @volunteer3
    create :hour, volunteer: @volunteer3, hourable: assignment3,
      hours: 2.5, meeting_date: date

    @volunteer4 = create :volunteer
    group_assignment4 = create :group_assignment, volunteer: @volunteer4
    billed_hour4 = create :hour, volunteer: @volunteer4,
      hourable: group_assignment4.group_offer,
      hours: 5.5, meeting_date: date - 1.month
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

    click_link 'Periode: Januar 2018 - Juni 2018'
    click_link 'Juli 2017 - Dezember 2017'

    assert_text "#{@volunteer4} #{@volunteer4.iban} 5.5 Stunden Fr. 50.00"
    refute_text @volunteer1

    click_link 'Periode: Juli 2017 - Dezember 2017'
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

    create :hour, volunteer: @volunteer1, hourable: @assignment1, hours: 1.5
    click_link 'Spesenformulare erstellen'

    assert_text "#{@volunteer1} UBS, #{@volunteer1.iban} 1.5 Stunden Fr. 50.00"
    refute_text @volunteer2
    assert_text "#{@volunteer3} Keine IBAN angegeben 2.5 Stunden Fr. 50.00"
    refute_text @volunteer4
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

  test 'download single billing expense' do
    use_rack_driver

    visit billing_expenses_path
    click_on 'Herunterladen', match: :first
    pdf = load_pdf(page.body)

    assert_equal 1, pdf.page_count
    assert_includes pdf.pages.first.text, "Spesenauszahlung an #{@volunteer1}"
  end

  test 'download multiple billing expenses' do
    use_rack_driver

    visit billing_expenses_path
    click_link 'Periode: Januar 2018 - Juni 2018'
    click_link 'Alle'

    page.all('input[type="checkbox"]').each(&:click)
    click_on 'Auswahl herunterladen'
    pdf = load_pdf(page.body)

    assert_equal 2, pdf.page_count
    assert_includes pdf.pages[0].text, "Spesenauszahlung an #{@volunteer4}"
    assert_includes pdf.pages[1].text, "Spesenauszahlung an #{@volunteer1}"
  end
end
