require 'application_system_test_case'

class ClientsTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user, email: 'superadmin@example.com'
    @department_manager = create :department_manager, email: 'department@example.com'
    @social_worker = create :social_worker
  end

  test 'new client form' do
    login_as @superadmin
    visit new_client_path

    fill_in 'First name', with: 'asdf'
    fill_in 'Last name', with: 'asdf'
    within '.client_birth_year' do
      select('1995', from: 'Birth year')
    end
    select('Mrs.', from: 'Salutation')
    select('Aruba', from: 'Nationality')
    fill_in 'Entry date', with: 'Sept. 2015'
    choose('client_permit_b')
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    fill_in 'Primary email', with: 'gurke@gurkenmail.com'
    fill_in 'Primary phone', with: '0123456789'
    fill_in 'Secondary phone', with: '0123456789'
    within '#languages' do
      choose('Good')
    end
    click_on('Sprache hinzufügen')
    select('Akan', from: 'Language')
    select('Fluent', from: 'Level')
    click_on('Add family member')
    within '#relatives' do
      fill_in 'First name', with: 'asdf'
      fill_in 'Last name', with: 'asdf'
      select('2001', from: 'Birth year')
      select('Uncle', from: 'Relation')
    end
    fill_in 'Goals', with: 'asdfasdf'
    select("gender doesn't matter", from: "Volunteer's gender")
    select('36 - 50', from: "Volunteer's age")
    fill_in 'Other request', with: 'asdfasdf'
    fill_in 'Education', with: 'asdfasdf'
    fill_in 'Actual activities', with: 'asdfasdf'
    fill_in 'Interests', with: 'asdfasdf'
    select('Angemeldet', from: 'Acceptance')
    fill_in 'Comments', with: 'asdfasdf'
    fill_in 'Competent authority', with: 'asdfasdf'
    select('social_worker', from: 'Involved authority')
    select('Gemeinde', from: 'Cost unit')
    page.check('client_evening')
    fill_in 'Detailed Description', with: 'After 7'

    click_button 'Create Client'
    assert page.has_text? 'Client was successfully created.'
    assert page.has_text? @social_worker.full_name
    @superadmin.clients.each do |client|
      assert page.has_link? client.involved_authority.full_name, href: /profiles\/#{client.involved_authority.profile.id}/
      assert page.has_link? client.user.full_name, href: /profiles\/#{client.user.profile.id}/
      assert page.has_link? client.contact.primary_email
    end
  end

  test 'new client form with preselected fields' do
    login_as @superadmin
    visit new_client_path
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'Client'
    fill_in 'Last name', with: "doesn't matter"
    fill_in 'Primary phone', with: '0123456789'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    within '#languages' do
      choose('Good')
    end
    click_button 'Create Client'
    assert page.has_text? 'Client was successfully created.'
    within '.table-no-border-top' do
      assert page.has_text? "age doesn't matter"
      assert page.has_text? "gender doesn't matter"
      assert page.has_text? 'German Good'
    end
  end

  test 'new client can select custom language' do
    login_as @superadmin
    visit new_client_path
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'Dari'
    fill_in 'Last name', with: 'Dari'
    fill_in 'Primary email', with: 'client@aoz.com'
    fill_in 'Primary phone', with: '0123456789'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'

    within '#languages' do
      choose('Good')
    end

    click_on('Sprache hinzufügen')
    select('Dari', from: 'Language')
    select('Native speaker', from: 'Level')

    click_button 'Create Client'
    assert page.has_text? 'Client was successfully created.'
    within '.table-no-border-top' do
      assert page.has_text? 'Dari Native speaker'
      assert page.has_text? 'German Good'
    end
  end

  test 'level without a language is not shown' do
    login_as @superadmin
    visit new_client_path
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'asdf'
    fill_in 'Last name', with: 'asdf'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    fill_in 'Primary email', with: 'gurke@gurkenmail.com'
    fill_in 'Primary phone', with: '0123456789'
    within '#languages' do
      choose('Basic')
    end

    click_on('Sprache hinzufügen')
    select('Fluent', from: 'Level')

    click_button 'Create Client'
    within '.table-no-border-top' do
      refute page.has_text? 'Fluent'
      assert page.has_text? 'German Basic'
    end

    visit clients_path
    refute page.has_text? 'Fluent'
  end

  test 'superadmin_can_delete_client' do
    login_as @superadmin
    client = create :client
    visit client_path(client)

    page.accept_confirm do
      first('a', text: 'Delete').click
    end

    assert page.has_text? 'Client was successfully deleted.'
  end

  test 'client pagination' do
    login_as @superadmin
    70.times do
      create :client
    end
    visit clients_path
    first(:link, '2').click

    assert page.has_css? '.pagination'
    Client.order('created_at desc').paginate(page: 2).each do |client|
      assert page.has_text? client.contact.last_name
    end
  end

  test 'superadmin_sees_all_required_features_in_index' do
    with_assignment, without_assignment = create_clients_for_index_text_check
    login_as @superadmin
    visit clients_path
    assert page.has_text? with_assignment.contact.full_name
    assert page.has_text? without_assignment.contact.full_name
    assert page.has_text? 'unassigned_goals unassigned_interests  unassigned_authority '\
      "#{I18n.l(without_assignment.created_at.to_date)} Angemeldet without_assignment Show Edit"
    assert page.has_text? 'assigned_goals assigned_interests assigned_authority '\
      "#{I18n.l(with_assignment.created_at.to_date)} Angemeldet with_assignment Show Edit"
  end

  test 'can_delete_a_client_through_edit' do
    client = create :client
    login_as @superadmin

    visit clients_path
    assert page.has_text? client

    visit edit_client_path(client)
    page.accept_confirm do
      click_link 'Delete'
    end

    assert page.has_text? 'Client was successfully deleted.'
    refute page.has_text? client
  end

  test 'all_needed_actions_are_available_in_the_index' do
    client = create :client
    social_worker = create :social_worker
    client_department_manager = create :client, user: @department_manager
    client_social_worker = create :client, user: social_worker

    login_as @superadmin
    visit clients_path
    assert page.has_link? 'Show', count: 3
    assert page.has_link? 'Edit', count: 3
    refute page.has_link? 'Delete'

    login_as @department_manager
    visit clients_path
    assert page.has_text? client_department_manager
    refute page.has_text? client_social_worker
    refute page.has_text? client
    assert page.has_link? 'Show'
    refute page.has_link? 'Edit'
    refute page.has_link? 'Delete'

    login_as social_worker
    visit clients_path
    assert page.has_text? client_social_worker
    refute page.has_text? client_department_manager
    refute page.has_text? client
    assert page.has_link? 'Show'
    assert page.has_link? 'Edit'
    refute page.has_link? 'Delete'
  end

  test 'department_manager_sees_his_scoped_client_index_correctly' do
    superadmins_client = create :client, user: @superadmin
    with_assignment, without_assignment = create_clients_for_index_text_check
    with_assignment.update(user: @department_manager)
    without_assignment.update(user: @department_manager)
    login_as @department_manager
    visit clients_path
    assert page.has_text? with_assignment.contact.full_name
    assert page.has_text? without_assignment.contact.full_name
    assert page.has_text? 'unassigned_goals unassigned_interests unassigned_authority '\
      "#{I18n.l(without_assignment.created_at.to_date)} Show"
    assert page.has_text? 'assigned_goals assigned_interests assigned_authority '\
      "#{I18n.l(with_assignment.created_at.to_date)} Show"
    refute page.has_text? superadmins_client.contact.full_name
  end

  test 'client_index_shows_german_and_native_languages_only' do
    create :client, language_skills: [
      create(:language_skill, language: 'DE', level: 'good'),
      create(:language_skill, language: 'IT', level: 'native_speaker'),
      create(:language_skill, language: 'FR', level: 'fluent')
    ]
    login_as @superadmin
    visit clients_path
    assert page.has_text? 'German, Good'
    assert page.has_text? 'Italian, Native speaker'
    refute page.has_text? 'French, Fluent'
  end

  test 'new_client_form_has_german_with_its_non_native_speaker_abilities' do
    login_as @superadmin
    visit new_client_path
    assert page.has_text? 'Sprachkenntnisse Deutsch * Level'
    within '#languages' do
      choose('Basic')
    end
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'Client'
    fill_in 'Last name', with: "doesn't matter"
    fill_in 'Primary email', with: 'client@aoz.com'
    fill_in 'Primary phone', with: '0123456789'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    click_button 'Create Client'
    assert page.has_text? 'German Basic'
  end

  test 'client_print_view_is_not_paginated' do
    45.times { create :client }
    login_as @superadmin
    visit clients_url(print: true)
    assert_equal Client.count, find_all('tbody tr').size
  end

  def create_clients_for_index_text_check
    with_assignment = create :client, comments: 'with_assignment',
                              competent_authority: 'assigned_authority',
                              goals: 'assigned_goals', interests: 'assigned_interests'
    create :assignment, volunteer: create(:volunteer), client: with_assignment
    with_assignment.update(created_at: 2.days.ago)
    without_assignment = create :client, comments: 'without_assignment',
                                competent_authority: 'unassigned_authority',
                                goals: 'unassigned_goals', interests: 'unassigned_interests'
    without_assignment.update(created_at: 4.days.ago)
    [with_assignment, without_assignment]
  end

  test 'If social worker registers a client, she is automatically the involved authority' do
    login_as @social_worker
    visit new_client_path

    within '#languages' do
      choose('Basic')
    end
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'Client'
    fill_in 'Last name', with: "doesn't matter"
    fill_in 'Primary email', with: 'client@aoz.com'
    fill_in 'Primary phone', with: '0123456789'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    refute page.has_select? 'Involved authority'

    click_button 'Create Client'

    login_as @superadmin
    visit client_path(Client.last)
    assert page.has_link? @social_worker.full_name, count: 2
  end
end
