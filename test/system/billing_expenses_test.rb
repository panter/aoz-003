require 'application_system_test_case'

class BillingExpensesTest < ApplicationSystemTestCase
  def setup
    superadmin = create :user
    @volunteer = create :volunteer
    assignment = create :assignment, volunteer: @volunteer
    create :hour, volunteer: @volunteer, assignment: assignment
    login_as superadmin
    visit volunteer_path(@volunteer)
    click_link 'New Billing expense'
    click_button 'Create Billing expense'
  end

  test 'superadmin can create a billing expense' do
    assert page.has_text? 'Billing expense was successfully created.'
  end

  test 'no duplicate billing expenses' do
    click_link 'New Billing expense'
    click_button 'Create Billing expense'
    assert_no_difference 'BillingExpense.count' do
      click_link 'New Billing expense'
      click_button 'Create Billing expense'
      assert page.has_text? 'This billing expense was already created'
    end
  end

  test 'created billing expenses has needed fields' do
    within '.table-responsive' do
      assert page.has_link? @volunteer.contact.full_name
      assert page.has_text? @volunteer.contact.full_address
      click_link 'Show'
    end
    assert page.has_text? 'Spesenauszahlung an'
    assert page.has_text? 'Kostenstelle'
    assert page.has_text? '4182'
    assert page.has_text? 'Konto'
    assert page.has_text? '4621'
    assert page.has_text? 'zu überweisender Betrag'
    assert page.has_text? 'Name'
    assert page.has_text? 'Vorname'
    assert page.has_text? 'Strasse'
    assert page.has_text? 'PLZ / Ort'
    assert page.has_text? 'Bank / IBAN'
  end

  test 'created billing expenses has needed fields' do
    visit volunteer_path(@volunteer)
    click_link 'New Billing expense'
    select '100', from: 'Amount'
    click_button 'Create Billing expense'
    assert page.has_text? 'Billing expense was successfully created.'

    visit volunteer_billing_expense_path(@volunteer, record)
    assert page.has_text? 'Spesenauszahlung an'
    assert page.has_text? 'Kostenstelle'
    assert page.has_text? '4182'
    assert page.has_text? 'Konto'
    assert page.has_text? '4621'
    assert page.has_text? 'zu überweisender Betrag'
    assert page.has_text? @billing_expense.amount
    assert page.has_text? 'Name'
    assert page.has_text? @volunteer.contact.last_name
    assert page.has_text? 'Vorname'
    assert page.has_text? @volunteer.contact.first_name
    assert page.has_text? 'Strasse'
    assert page.has_text? @volunteer.contact.street
    assert page.has_text? 'PLZ / Ort'
    assert page.has_text? @volunteer.contact.postal_code
    assert page.has_text? @volunteer.contact.city
    assert page.has_text? 'Bank / IBAN'
  end
end
