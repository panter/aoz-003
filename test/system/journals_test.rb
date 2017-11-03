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

  test 'can_create_journal_entry_by_link_button_in_show' do
    visit client_path(@client)
    first('a', text: 'Journal').click
    click_link 'New Journal'
    assert page.has_text? 'New Journal'
    fill_in 'Body', with: 'My bogus demo text body, just for this test.'
    select('Telephone', from: 'Category')
    click_button 'Create journal'
    assert page.has_text? 'Journal was successfully created.'
    first('a', text: 'Journal').click
    assert page.has_text? 'My bogus demo text body, just for this test.'
  end

  test 'can_delete_a_journal_through_edit' do
    superadmin = create :user
    Journal.with_deleted.map(&:really_destroy!)
    create :journal, journalable: @volunteer, user: superadmin, body: 'bogus_journal_text'
    login_as superadmin
    visit volunteer_path(@volunteer)

    click_button 'Journal'
    assert page.has_text? 'bogus_journal_text'
    first('a', text: 'Edit').click
    assert page.has_text? 'Edit Journal'
    page.accept_confirm do
      first('a', text: 'Delete').click
    end
    assert page.has_text? 'Journal was successfully deleted.'
    click_button 'Journal'
    refute page.has_link? @journal_volunteer.user.full_name
    refute page.has_text? @journal_volunteer.body
  end
end
