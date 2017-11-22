require 'application_system_test_case'

class EmailTemplatesTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @other_email_template = create :email_template
    @email_template = create :email_template, active: true
    login_as @user
    visit email_templates_path
  end

  test 'the right email template should be marked active' do
    assert page.has_text? @email_template.subject
    within 'tr.bg-success' do
      assert page.has_text? @email_template.subject
      refute page.has_text? @other_email_template.subject
    end
  end

  test 'changing another email to active deactivates the former active' do
    within 'tbody tr:last-child' do
      assert page.has_text? @other_email_template.subject
      click_link 'Edit'
    end
    page.check('email_template_active')
    click_button 'Update E-mailvorlage'
    click_link 'Back'
    within 'tr.bg-success' do
      refute page.has_text? @email_template.subject
      assert page.has_text? @other_email_template.subject
    end
  end
end
