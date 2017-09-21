require 'application_system_test_case'

class InternExternVolunteersTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    login_as @user
  end

  test 'Volunteer can be created as extern' do
    visit volunteers_path
    click_link 'New Volunteer'
    check 'Register the volunteer as external?'
    select 'Mr.', from: 'Salutation'
    fill_in 'First name', with: 'Heiri'
    fill_in 'Last name', with: 'Bitterli'
    fill_in 'Street', with: 'Strasse xyz'
    fill_in 'Zip', with: '8001'
    fill_in 'City', with: 'Zürich'
    click_button 'Create Volunteer'
    assert page.has_text? 'Volunteer was successfully created.'
    assert page.has_text? 'External'
    visit volunteers_path
    within 'tbody' do
      assert page.has_text? 'External'
    end
  end
end
