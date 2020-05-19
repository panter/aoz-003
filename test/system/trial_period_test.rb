require 'application_system_test_case'

class TrialPeriodTest < ApplicationSystemTestCase
  setup do
    @user = create :superadmin
    @client = create :client_common
    @volunteer = create :volunteer_common
    login_as @user
  end

  test 'creating new assignment form has trial period end field' do
    visit new_assignment_path(client_id: @client.id, volunteer_id: @volunteer.id)
    fill_in 'Einsatzbeginn', with: Date.current.strftime('%d.%m.%Y')
    fill_in 'Probezeit bis', with: 4.weeks.from_now.strftime('%d.%m.%Y')
    click_button 'Begleitung erfassen', match: :first
    visit trial_periods_path(not_verified: true)
    assignment = @client.reload.assignments.last
    within "tr.trial-period-id-#{assignment.trial_period.id}" do
      assert_text 4.weeks.from_now.strftime('%d.%m.%Y')
      assert page.has_link? assignment.to_label, href: polymorphic_path(assignment, action: :edit)
      assert page.has_link? 'Quittieren'
    end
  end
end
