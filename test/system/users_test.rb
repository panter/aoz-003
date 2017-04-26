require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  setup do
    @emails = ActionMailer::Base.deliveries
    @emails.clear
    @user = create :user, email: 'superadmin@example.com'
    login_as @user
    visit new_user_path
  end

  test 'invalid superadmin information' do
    fill_in 'Email', with: ''
    select '', from: 'Role'

    assert_no_difference 'User.count' do
      click_button 'Create User'
      within('div.modal') do
        click_button 'Create User'
      end

      assert page.has_text? 'Please review the problems below:'
      assert page.has_text? "can't be blank"
      assert page.has_text? 'is not included in the list'
    end
  end

  test 'invalid user role' do
    fill_in 'Email', with: 'superadmin@test.ch'
    select '', from: 'Role'

    assert_no_difference 'User.count' do
      click_button 'Create User'
      within('div.modal') do
        click_button 'Create User'
      end

      assert page.has_text? 'Please review the problems below:'
      assert page.has_text? 'is not included in the list'
    end
  end

  test 'taken user email' do
    fill_in 'Email', with: 'superadmin@example.com'
    select 'superadmin', from: 'Role'

    assert_no_difference 'User.count' do
      click_button 'Create User'
      within('div.modal') do
        click_button 'Create User'
      end

      assert page.has_text? 'Please review the problems below:'
      assert page.has_text? 'has already been taken'
    end
  end

  test 'valid superadmin registration' do
    fill_in 'Email', with: 'superadmin@test.ch'
    select 'superadmin', from: 'Role'

    assert_difference 'User.count', 1 do
      click_button 'Create User'
      within('div.modal') do
        click_button 'Create User'
      end

      assert page.has_text? 'Invitation sent to superadmin@test.ch'
    end

    within('nav') do
      click_link 'superadmin@example.com'
    end
    click_link 'Logout'

    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.last
    assert_equal 'superadmin@test.ch', email['to'].to_s
  end
end
