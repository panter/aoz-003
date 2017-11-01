require 'application_system_test_case'

class ClientsTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user, email: 'superadmin@example.com'
    @department_manager = create :department_manager, email: 'department@example.com'
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
    page.choose('client_permit_b')
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    fill_in 'Primary email', with: 'gurke@gurkenmail.com'
    fill_in 'Primary phone', with: '0123456789'
    fill_in 'Secondary phone', with: '0123456789'
    click_on('Add language')
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
    select('gender same', from: "Volunteer's gender")
    select('36 - 50', from: "Volunteer's age")
    fill_in 'Other request', with: 'asdfasdf'
    fill_in 'Education', with: 'asdfasdf'
    fill_in 'Actual activities', with: 'asdfasdf'
    fill_in 'Interests', with: 'asdfasdf'
    select('Active', from: 'State')
    fill_in 'Comments', with: 'asdfasdf'
    fill_in 'Competent authority', with: 'asdfasdf'
    fill_in 'Involved authority', with: 'asdfasdf'
    page.check('client_evening')
    fill_in 'Detailed Description', with: 'After 7'

    click_button 'Create Client'
    assert page.has_text? 'Client was successfully created.'
  end

  test 'new client form with preselected fields' do
    login_as @superadmin
    visit new_client_path
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'Client'
    fill_in 'Last name', with: "doesn't matter"
    fill_in 'Primary email', with: 'client@aoz.com'
    fill_in 'Primary phone', with: '0123456789'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    click_button 'Create Client'
    assert page.has_text? 'Client was successfully created.'
    within '.table-no-border-top' do
      assert page.has_text? "age doesn't matter"
      assert page.has_text? "gender doesn't matter"
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

    click_on('Add language')
    select('Dari', from: 'Language')
    select('Native speaker', from: 'Level')

    click_button 'Create Client'
    assert page.has_text? 'Client was successfully created.'
    within '.table-no-border-top' do
      assert page.has_text? 'Dari Native speaker'
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

    click_on('Add language')
    select('Fluent', from: 'Level')

    click_button 'Create Client'
    within '.table-no-border-top' do
      refute page.has_text? 'Fluent'
    end

    visit clients_path
    refute page.has_text? 'Fluent'
  end

  test 'superadmin can delete client' do
    login_as @superadmin
    client = create :client
    visit client_path(client)
    first('a', text: 'Delete').click

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
    Client.paginate(page: 2).each do |client|
      assert page.has_text? client.contact.last_name
    end
  end

  test 'superadmin sees all required features in index' do
    with_assignment, without_assignment = create_clients_for_index_text_check
    login_as @superadmin
    visit clients_path
    assert page.has_text? with_assignment.contact.full_name
    assert page.has_text? without_assignment.contact.full_name
    assert page.has_text? 'unassigned_goals unassigned_interests unassigned_authority without_assignment '\
      "#{I18n.l(without_assignment.created_at.to_date)} Show Find volunteer"
    assert page.has_text? 'assigned_goals assigned_interests assigned_authority with_assignment '\
      "#{I18n.l(with_assignment.created_at.to_date)} Show Show Assignment"
  end

  test 'department manager sees his scoped client index correctly' do
    superadmins_client = create :client, user: @superadmin
    with_assignment, without_assignment = create_clients_for_index_text_check
    with_assignment.update(user: @department_manager)
    without_assignment.update(user: @department_manager)
    login_as @department_manager
    visit clients_path
    assert page.has_text? with_assignment.contact.full_name
    assert page.has_text? without_assignment.contact.full_name
    assert page.has_text? 'unassigned_goals unassigned_interests unassigned_authority without_assignment '\
      "#{I18n.l(without_assignment.created_at.to_date)} Show Find volunteer"
    assert page.has_text? 'assigned_goals assigned_interests assigned_authority with_assignment '\
      "#{I18n.l(with_assignment.created_at.to_date)} Show Show Assignment"
    refute page.has_text? superadmins_client.contact.full_name
  end

  def create_clients_for_index_text_check
    with_assignment = create :client, comments: 'with_assignment', competent_authority: 'assigned_authority',
                             goals: 'assigned_goals', interests: 'assigned_interests'
    create :assignment, volunteer: create(:volunteer), client: with_assignment
    with_assignment.update(created_at: 2.days.ago)
    without_assignment = create :client, comments: 'without_assignment', competent_authority: 'unassigned_authority',
                                goals: 'unassigned_goals', interests: 'unassigned_interests'
    without_assignment.update(created_at: 4.days.ago)
    [with_assignment, without_assignment]
  end
end
