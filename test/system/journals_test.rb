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
    first(:link, 'Journal').click

    assert_link @journal_volunteer.user.full_name
    assert_text @journal_volunteer.body
  end

  test 'can_create_journal' do
    visit client_journals_path(create(:client))
    click_link 'Journal erfassen'

    assert_text 'Journal erfassen'

    fill_in 'Titel', with: 'Bogus Title'
    fill_in 'Text', with: 'My bogus demo text body, just for this test.'
    select 'Telefonat', from: 'Kategorie'
    click_button 'Journaleintrag speichern'

    assert_text 'Journal wurde erfolgreich erstellt.'
    assert_text 'Bogus Title'
    assert_text 'My bogus demo text body, just for this test.'
  end

  test 'can_edit_journal' do
    visit volunteer_journals_path(@volunteer)
    click_link 'Bearbeiten'

    assert_text 'Journal bearbeiten'

    fill_in 'Text', with: 'New text'
    click_button 'Journaleintrag aktualisieren'

    assert_text 'Journal wurde erfolgreich geändert.'
    assert_text 'New text'
  end

  test 'can_delete_journal' do
    visit volunteer_journals_path(@volunteer)

    assert_text @journal_volunteer.body

    click_link 'Bearbeiten'

    assert_text 'Journal bearbeiten'

    page.accept_confirm do
      click_link 'Löschen'
    end

    assert_text 'Journal wurde erfolgreich gelöscht.'
    assert_text 'Journal Liste'
    refute_text @journal_volunteer.body
  end
end
