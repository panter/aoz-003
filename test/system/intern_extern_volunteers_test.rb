require 'application_system_test_case'

class InternExternVolunteersTest < ApplicationSystemTestCase
  def setup
    @user = create :user

    login_as @user
  end

  test 'Volunteer can be created as extern' do
    visit volunteers_path
    click_link 'New Volunteer'
    assert page.has_field? 'External'
  end
end
