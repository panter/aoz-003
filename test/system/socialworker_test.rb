require 'application_system_test_case'

class SocialworkerTest < ApplicationSystemTestCase
  def setup
    @socialworker = create :social_worker
  end

  test 'when logged in socialworker cannot see create superadmin link' do
    login_as @socialworker, scope: :socialworker
    visit root_path

    assert_not page.has_link? 'Create superadmin'
  end

  test 'when updates user login, cannot see role field' do
    login_as @socialworker, scope: :socialworker
    visit edit_user_path(@socialworker)
    assert_not page.has_field? 'role'
  end
end
