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
      accept_prompt do
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
      accept_prompt do
        click_button 'Create User'
      end
      assert page.has_text? 'Please review the problems below:'
      assert page.has_text? 'is not included in the list'
    end
  end

  test 'taken user email' do
    fill_in 'Email', with: 'superadmin@example.com'
    select 'Superadmin', from: 'Role'

    assert_no_difference 'User.count' do
      accept_prompt do
        click_button 'Create User'
      end
      assert page.has_text? 'Please review the problems below:'
      assert page.has_text? 'has already been taken'
    end
  end

  test 'valid superadmin registration' do
    fill_in 'Email', with: 'superadmin@test.ch'
    select 'Superadmin', from: 'Role'

    assert_difference 'User.count', 1 do
      accept_prompt do
        click_button 'Create User'
      end
      assert page.has_text? 'Invitation sent to superadmin@test.ch'
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.last
    assert_equal 'superadmin@test.ch', email['to'].to_s
  end

  test 'superadmin can destroy social worker' do
    create :user, role: 'social_worker'
    visit users_path

    assert page.has_link? 'Delete'
  end

  test "superadmin can't destroy superadmin" do
    create :user, role: 'superadmin'
    visit users_path

    assert_not page.has_link? 'Delete'
  end

  test 'accepted volunteer becomes a user' do
    volunteer = create :volunteer

    visit edit_volunteer_path(volunteer.id)
    select('Accepted', from: 'State')
    assert_difference 'User.count', 1 do
      click_button 'Update Volunteer'
<<<<<<< HEAD
    end
    assert page.has_text? "Invitation sent to #{volunteer.email}"
    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.last
    assert_equal volunteer.email, email['to'].to_s
=======
      assert page.has_text? "Invitation sent to #{volunteer.contact.contact_emails.first.body}"
    end

    volunteer.contact.contact_emails.first.body
    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.last
    assert_equal volunteer.contact.contact_emails.first.body, email['to'].to_s
>>>>>>> adapt volunteer tests after contact field integration
  end
end
