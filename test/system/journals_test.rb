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
    click_link 'Journal erfassen'

    assert page.has_text? 'Journal erfassen'

    fill_in 'Titel', with: 'Bogus Title'
    fill_in 'Text', with: 'My bogus demo text body, just for this test.'
    select('Telefonat', from: 'Kategorie')
    click_button 'Journaleintrag speichern'

    assert page.has_text? 'Journal wurde erfolgreich erstellt.'
    assert page.has_text? 'Bogus Title'
    assert page.has_text? 'My bogus demo text body, just for this test.'
  end

  test 'can_delete_a_journal_through_edit' do
    visit volunteer_path(@volunteer)

    click_link 'Journal'
    assert page.has_text? @journal_volunteer.body
    first('a', text: 'Bearbeiten').click
    assert page.has_text? 'Journal bearbeiten'
    page.accept_confirm do
      first('a', text: 'Löschen').click
    end
    assert page.has_text? 'Journal wurde erfolgreich gelöscht.'
    click_link 'Journal'
    refute page.has_text? @journal_volunteer.body
  end
end
