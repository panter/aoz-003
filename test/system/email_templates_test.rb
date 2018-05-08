require 'application_system_test_case'

class EmailTemplatesTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @other_email_template = create :email_template
    @email_template = create :email_template, active: true
    login_as @user
  end

  test 'the right email template should be marked active' do
    visit email_templates_path
    assert page.has_text? @email_template.subject
    within 'tr.bg-success' do
      assert page.has_text? @email_template.subject
      refute page.has_text? @other_email_template.subject
    end
  end

  test 'changing another email to active deactivates the former active' do
    visit email_templates_path
    within 'tbody tr:last-child' do
      assert page.has_text? @other_email_template.subject
      click_link 'Bearbeiten'
    end
    page.check('Aktiv')
    click_button 'E-Mailvorlage aktualisieren'
    click_link 'Zurück'
    within 'tr.bg-success' do
      refute page.has_text? @email_template.subject
      assert page.has_text? @other_email_template.subject
    end
  end

  test 'sign up email template shows no variables' do
    visit new_email_template_path

    within '#email_template_kind' do
      select('Anmeldung')
    end

    assert_text 'Für diese E-Mailvorlage gibt es keine Platzhalter.'
    refute_text 'Sie können die folgenden Platzhalter benützen:'
    refute_text 'Zum Beispiel: %{Anrede} %{Name}'
  end

  # test 'trial email template shows variables' do
  #   visit new_email_template_path

  #   within '#email_template_kind' do
  #     select('Probezeit')
  #   end
  #   wait_for_ajax
  #   refute_text 'Für diese E-Mailvorlage gibt es keine Platzhalter.'
  #   assert_text 'Sie können die folgenden Platzhalter benützen:'
  #   assert_text 'Zum Beispiel: %{Anrede} %{Name}'
  # end

  # test 'half year email template shows variables' do
  #   visit new_email_template_path

  #   within '#email_template_kind' do
  #     select('Halbjährlich')
  #   end
  #   refute_text 'Für diese E-Mailvorlage gibt es keine Platzhalter.'
  #   assert_text 'Sie können die folgenden Platzhalter benützen:'
  #   assert_text 'Zum Beispiel: %{Anrede} %{Name}'
  # end

  # test 'termination email template shows variables' do
  #   visit new_email_template_path

  #   within '#email_template_kind' do
  #     select('Beendigung')
  #   end
  #   refute_text 'Für diese E-Mailvorlage gibt es keine Platzhalter.'
  #   assert_text 'Sie können die folgenden Platzhalter benützen:'
  #   assert_text 'Zum Beispiel: %{Anrede} %{Name}'
  # end
end
