require 'application_system_test_case'

class InternExternVolunteersTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    login_as @user
  end

  test 'Volunteer can be created as extern' do
    visit volunteers_path
    first(:link, 'Freiwillige/n erfassen').click
    check 'Als externen Freiwilligen registrieren?'
    select 'Herr', from: 'Anrede'
    fill_in 'Vorname', with: 'Heiri'
    fill_in 'Nachname', with: 'Bitterli'
    fill_in 'Strasse', with: 'Strasse xyz'
    fill_in 'PLZ', with: '8001'
    fill_in 'Ort', with: 'Zürich'
    fill_in 'Mailadresse', with: FFaker::Internet.unique.email
    fill_in 'Telefonnummer', with: '123456789'
    fill_in 'Geburtsdatum', with: '12.10.1977'
    first(:button, 'Freiwillige/n erfassen').click
    assert page.has_text? 'Freiwillige/r wurde erfolgreich erstellt.'
    assert page.has_text? 'Extern'
    visit volunteers_path
    within 'tbody' do
      assert page.has_text? 'Extern'
    end
  end
end
