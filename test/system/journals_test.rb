require 'application_system_test_case'

class JournalsTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @department_manager = create :user, :department_manager
    @volunteer = create :volunteer, registrar: @department_manager, acceptance: :accepted
    @volunteer.journals = [FactoryBot.create(:journal, user: @volunteer.user)]
    @journal_volunteer = @volunteer.journals.reload.first
  end

  def volunteer_has_link_to_their_journal_entry_as(user)
    login_as user
    visit volunteer_path(@volunteer)
    first(:link, 'Journal').click

    assert_link @journal_volunteer.user.full_name
    assert_text @journal_volunteer.body
  end

  test 'volunteer has link to their journal entry as a superadmin' do
    volunteer_has_link_to_their_journal_entry_as @superadmin
  end

  test 'volunteer has link to their journal entry as a department manager' do
    volunteer_has_link_to_their_journal_entry_as @superadmin
  end

  def can_create_journal_as(user)
    login_as user
    visit client_journals_path(create(:client))
    click_link 'Journal erfassen', match: :first

    assert_text 'Journal erfassen'

    fill_in 'Titel', with: 'Bogus Title'
    fill_in 'Text', with: 'My bogus demo text body, just for this test.'
    select 'Telefonat', from: 'Kategorie'
    click_button 'Journaleintrag speichern'

    assert_text 'Journal wurde erfolgreich erstellt.'
    assert_text 'Bogus Title'
    assert_text 'My bogus demo text body, just for this test.'
  end

  test 'can create journal as superadmin' do
    can_create_journal_as @superadmin
  end

  test 'can create journal as department manager' do
    can_create_journal_as @department_manager
  end

  def can_edit_journal_as(user)
    login_as user
    visit volunteer_journals_path(@volunteer)
    click_link 'Bearbeiten'

    assert_text 'Journal bearbeiten'

    fill_in 'Text', with: 'New text'
    click_button 'Journaleintrag aktualisieren'

    assert_text 'Journal wurde erfolgreich geändert.'
    assert_text 'New text'
  end

  test 'can edit journal as superadmin' do
    can_edit_journal_as @superadmin
  end

  test 'can edit journal as department manager' do
    can_edit_journal_as @department_manager
  end

  def can_delete_journal_as(user)
    login_as user
    visit volunteer_journals_path(@volunteer)

    assert_text @journal_volunteer.body

    click_link 'Bearbeiten'

    assert_text 'Journal bearbeiten'

    page.accept_confirm do
      click_link 'Löschen'
    end

    assert_text 'Journal wurde erfolgreich gelöscht.'
    assert_text 'Journal Liste'
    refute_text @journal_volunteer.body, wait: 0
  end

  test 'can delete journal as superadmin' do
    can_delete_journal_as @superadmin
  end

  test 'can delete journal as department manager' do
    can_delete_journal_as @department_manager
  end
end
