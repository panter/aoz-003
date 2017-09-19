require 'application_system_test_case'

class JournalsTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @volunteer = create :volunteer, journals: [FactoryGirl.create(:journal, user: @user)]
    @client = create :client, journals: [FactoryGirl.create(:journal, user: @user)]
    @journal_volunteer = @volunteer.journals.first
    @client_volunteer = @client.journals.first
  end

  test 'volunteer has link to his journal entry' do
    login_as @user
    visit volunteer_path(@volunteer)
    click_button 'Journal'
    within '.collapse .table-responsive' do
      assert page.has_text? @journal_volunteer.subject
      assert page.has_link? @journal_volunteer.user.full_name
      click_link 'Show'
    end
    assert page.has_text? 'Show Journal'
    assert page.has_text? @journal_volunteer.subject
    assert page.has_text? @journal_volunteer.body
    assert page.has_link? @journal_volunteer.user.full_name
  end

  test 'can create journal entry by link button in show and then delete it' do
    login_as @user
    visit client_path(@client)
    click_button 'Journal'
    click_link 'Write a journal entry'
    assert page.has_text? 'New Journal'
    fill_in 'Subject', with: 'My bogus demo subject, i want to ad here.'
    fill_in 'Body', with: 'My bogus demo text body, just for this test.'
    select('Telephone', from: 'Category')
    click_button 'Create journal'
    click_button 'Journal'
    within '.collapse .table-responsive' do
      assert page.has_text? 'My bogus demo subject, i want to ad here.'
      assert page.has_text? 'My bogus demo text body, just for this test.'.truncate(40)
      within 'tbody tr:first-child' do
        click_link 'Delete'
      end
    end
    click_button 'Journal'
    refute page.has_text? 'My bogus demo subject, i want to ad here.'
    refute page.has_text? 'My bogus demo text body, just for this test.'.truncate(40)
  end
end
