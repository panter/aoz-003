require 'application_system_test_case'

class InternExternVolunteersTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    login_as @user
  end

  test 'Volunteer can be created as extern' do
    visit volunteers_path
    click_link 'New Volunteer'
    check 'Register the Volunteer as external?'
    assert page.has_select? 'State', selected: 'Accepted'
  end
end
