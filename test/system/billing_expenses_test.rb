require 'application_system_test_case'

class BillingExpensesTest < ApplicationSystemTestCase
  def setup
    superadmin = create :user
    @volunteer = create :volunteer
    @assignment = create :assignment, volunteer: @volunteer, period_start: 9.months.ago
    @hour1 = create :hour, volunteer: @volunteer, hourable: @assignment, hours: '2.5'
    @group_offer = create :group_offer
    @group_assignment = create :group_assignment, volunteer: @volunteer, period_start: 9.months.ago
    @hour2 = create :hour, hourable: @group_offer, volunteer: @volunteer, hours: '3.5'

    login_as superadmin
    visit volunteer_path(@volunteer)
    click_link 'Spesenformular Liste', match: :first
    click_button 'Spesenformular erfassen'
  end

  test 'superadmin can create a billing expense' do
    assert page.has_text? 'Spesenformular wurde erfolgreich erstellt.'
  end

  test 'created billing expenses collects hours from assignment and group offer' do
    within '.table-responsive' do
      assert_equal 6.0, @volunteer.hours.total_hours
      assert_equal 50, @volunteer.billing_expenses.last.amount
    end
  end

  test 'no duplicate billing expenses' do
    click_button 'Spesenformular erfassen'
    visit volunteer_path(@volunteer)
    first(:link, 'Spesenformular Liste').click
    assert_no_difference 'BillingExpense.count' do
      click_button 'Spesenformular erfassen'
      assert page.has_text? 'Dieser Freiwillige hat keine verrechenbaren Stunden'
    end
  end

  test 'created billing expenses has needed fields' do
    within '.table-responsive' do
      assert page.has_link? @volunteer.contact.full_name
      assert page.has_text? @volunteer.contact.full_address
      click_link 'Anzeigen'
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

  test 'volunteer that has only group offers can create billing expenses' do
    volunteer = create :volunteer
    group_offer = create :group_offer, volunteers: [volunteer]
    volunteer.group_assignments.last.update(period_start: 2.months.ago)
    create :hour, hourable: group_offer, volunteer: volunteer, hours: '3'

    visit volunteer_path(volunteer)
    click_link 'Spesenformular Liste', match: :first
    click_button 'Spesenformular erfassen'
    assert page.has_text? 'Spesenformular wurde erfolgreich erstellt.'
  end
end
