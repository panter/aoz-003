require 'application_system_test_case'

class VolunteerEmailsTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @other_volunteer_email = create :volunteer_email, user: @user
    @volunteer_email = create :volunteer_email, active: true, user: @user
  end

  test 'the right volunteer email should be marked active' do
    login_as @user
    visit volunteer_emails_path
    assert page.has_text? @volunteer_email.subject
    within 'tr.bg-success' do
      assert page.has_text? @volunteer_email.title
      refute page.has_text? @other_volunteer_email.title
    end
  end

  test 'changing another email to active deactivates the former active' do
    login_as @user
    visit volunteer_emails_path
    within 'tbody tr:last-child' do
      assert page.has_text? @other_volunteer_email.subject
      click_link 'Edit'
    end
    page.check('volunteer_email_active')
    click_button 'Update Confirmation email'
    click_link 'Back'
    within 'tr.bg-success' do
      refute page.has_text? @volunteer_email.title
      assert page.has_text? @other_volunteer_email.title
    end
  end
end
