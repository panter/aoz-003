require 'application_system_test_case'

class JournalsTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @volunteer = create :volunteer, journals: [FactoryBot.create(:journal, user: @user)],
      acceptance: :accepted
    @journal_volunteer = @volunteer.journals.first
    login_as @user
  end

  test 'volunteer_has_link_to_their_journal_entry' do
    visit volunteer_path(@volunteer)
    click_link 'Journal'
    assert page.has_link? @journal_volunteer.user.full_name
    assert page.has_text? @journal_volunteer.body
  end

  test 'can_create_journal_entry_by_link_button_in_show' do
    visit client_path(create(:client))
    first('a', text: 'Journal').click
    click_link 'New Journal'
    assert page.has_text? 'New Journal'
    fill_in 'Body', with: 'My bogus demo text body, just for this test.'
    select('Telephone', from: 'Category')
    click_button 'Create journal entry'
    assert page.has_text? 'Journal was successfully created.'
    assert page.has_text? 'My bogus demo text body, just for this test.'
  end

  test 'can_delete_a_journal_through_edit' do
    visit volunteer_path(@volunteer)

    click_link 'Journal'
    assert page.has_text? @journal_volunteer.body
    first('a', text: 'Edit').click
    assert page.has_text? 'Edit Journal'
    page.accept_confirm do
      first('a', text: 'Löschen').click
    end
    assert page.has_text? 'Journal was successfully deleted.'
    click_link 'Journal'
    refute page.has_text? @journal_volunteer.body
  end
end
