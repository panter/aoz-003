require 'application_system_test_case'

class JournalsTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @volunteer = create :volunteer, journals: [FactoryBot.create(:journal, user: @user)],
      acceptance: :accepted
    @client = create :client, journals: [FactoryBot.create(:journal, user: @user)]
    @journal_volunteer = @volunteer.journals.first
    @client_volunteer = @client.journals.first
    login_as @user
  end

  test 'volunteer has link to his journal entry' do
    visit volunteer_path(@volunteer)
    click_button 'Journal'
    within '.collapse .table-responsive' do
      assert page.has_link? @journal_volunteer.user.full_name
      assert page.has_text? @journal_volunteer.body
    end
  end

  test 'can create journal entry by link button in show' do
    visit client_path(@client)
    click_button 'Journal'
    click_link 'Write a journal entry'
    assert page.has_text? 'New Journal'
    fill_in 'Body', with: 'My bogus demo text body, just for this test.'
    select('Telephone', from: 'Category')
    click_button 'Create journal'
  end

  test 'can delete a journal through edit' do
    visit volunteer_path(@volunteer)
    click_button 'Journal'
    within '.collapse .table-responsive' do
      assert page.has_link? @journal_volunteer.user.full_name
      assert page.has_text? @journal_volunteer.body
      click_link 'Edit'
    end

    assert_difference 'Journal.count', -1 do
      click_link 'Delete'
      assert page.has_text? 'Journal was successfully deleted.'
      click_button 'Journal'
      refute page.has_link? @journal_volunteer.user.full_name
      refute page.has_text? @journal_volunteer.body
    end
  end
end
