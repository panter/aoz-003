require 'application_system_test_case'

class IndexActionPartialsTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @client = create :client
    login_as @user
  end

  test 'client list shows all actions needed' do
    visit clients_path
    assert page.has_link? 'Show', href: client_path(@client)
    assert page.has_link? 'Edit', href: edit_client_path(@client)
    assert page.has_link? 'Print', href: client_path(@client) + '?print=true'
    assert page.has_link? 'Journal', href: client_journals_path(@client)
    assert page.has_link? 'Delete', href: client_path(@client)
  end

  test 'click on print link leads to new page that prints' do
    visit clients_path
    assert_equal page.windows.count, 1
    click_link 'Print'
    assert_equal page.windows.count, 2
    page.switch_to_window(page.windows[1])
    assert page.has_link? @client.user.email
  end

  test 'volunteer list shows all actions needed' do
    volunteer = create :volunteer
    visit volunteers_path
    assert page.has_link? 'Show', href: volunteer_path(volunteer)
    assert page.has_link? 'Edit', href: edit_volunteer_path(volunteer)
    assert page.has_link? 'Print', href: volunteer_path(volunteer) + '?print=true'
    assert page.has_link? 'Journal', href: volunteer_journals_path(volunteer)
    assert page.has_link? 'Delete', href: volunteer_path(volunteer)
  end

  test 'volunteer_email list shows all actions needed' do
    volunteer_email = create :volunteer_email
    visit volunteer_emails_path
    assert page.has_link? 'Show', href: volunteer_email_path(volunteer_email)
    assert page.has_link? 'Edit', href: edit_volunteer_email_path(volunteer_email)
    assert page.has_link? 'Print', href: volunteer_email_path(volunteer_email) + '?print=true'
    assert page.has_link? 'Delete', href: volunteer_email_path(volunteer_email)
  end

  test 'assignments list shows all actions needed' do
    assignment = create :assignment
    visit assignments_path
    assert page.has_link? 'Show', href: assignment_path(assignment)
    assert page.has_link? 'Edit', href: edit_assignment_path(assignment)
    assert page.has_link? 'Print', href: assignment_path(assignment) + '?print=true'
    assert page.has_link? 'Delete', href: assignment_path(assignment)
  end
end
