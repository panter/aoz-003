require 'application_system_test_case'

class DepartmentManagerTest < ApplicationSystemTestCase
  def setup
    @department_manager = create :department_manager
    3.times do
      create :client, user: @department_manager
    end
    login_as @department_manager
  end

  test 'when updates user login, cannot see role field' do
    visit edit_user_path(@department_manager)
    assert_not page.has_field? 'Role'
  end

  test 'does not have navbar links to users' do
    visit user_path(@department_manager.id)
    assert_not page.has_link? 'Benutzer/innen'
  end

  test 'has a navbar link to clients page' do
    visit user_path(@department_manager.id)
    assert page.has_link? 'Klienten/innen'
  end

  test 'can see his clients' do
    visit clients_path
    @department_manager.clients.each do |client|
      assert page.has_text? client.contact.first_name
      assert page.has_text? client.contact.last_name
      assert page.has_link? href: client_path(client.id)
    end
  end

  test 'can see a group offer volunteer and return to the group offer' do
    volunteer = create :volunteer
    group_offer = create :group_offer, volunteers: [volunteer],
      department: @department_manager.department.first
    visit volunteer_path(volunteer)
    assert page.has_link? group_offer.title
    visit group_offer_path(group_offer)
    assert page.has_link? volunteer.contact.full_name
  end

  test 'department manager has no destroy and feedback links on volunteer show' do
    volunteer = create :volunteer
    group_offer = create :group_offer, volunteers: [volunteer],
      department: @department_manager.department.first
    assignment = create :assignment, volunteer: volunteer
    visit volunteer_path(volunteer)
    assert page.has_link? group_offer.title
    assert page.has_link? assignment.client.contact.full_name
    refute page.has_link? 'Delete'
    refute page.has_link? 'New Feedback'
    refute page.has_link? 'Feedback index'
  end
end
