require 'application_system_test_case'

class RemindersTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @now = Time.zone.now.to_date
    @volunteer = create :volunteer
    @assignment = create :assignment, period_start: 7.months.ago.to_date, period_end: nil,
      volunteer: @volunteer, creator: @user
    Reminder.conditionally_create_reminders
    login_as @user
    visit reminders_path
  end

  test 'when reminder is sent, send button becomes sent date' do
    assert page.has_text? @now, count: 1
    click_button 'Send'
    assert page.has_text? @now, count: 2
  end

  test 'can delete reminder' do
    assert page.has_text? @volunteer.contact.full_name
    click_button 'Delete'
    refute page.has_text? @volunteer.contact.full_name
  end

  test 'when assignment is confirmed, reminder gets deleted' do
    assert page.has_text? @volunteer.contact.full_name
    visit edit_assignment_path(@assignment)
    page.check('assignment_confirmation')
    click_button 'Update Assignment'
    visit reminders_path
    refute page.has_text? @volunteer.contact.full_name
  end
end
