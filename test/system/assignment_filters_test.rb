require 'application_system_test_case'

class AssignmentFiltersTest < ApplicationSystemTestCase
  def setup
    @assignment_active = create :assignment_active
    @assignment_inactive = create :assignment_inactive
    login_as create(:user)
    visit assignments_path
  end

  test 'filter by activity' do
    assert page.has_link? @assignment_active.client.contact.full_name
    refute page.has_link? @assignment_inactive.client.contact.full_name
    within '.section-navigation' do
      click_link 'Status'
      click_link 'Aktiv'
    end
    visit current_url
    within 'tbody' do
      assert page.has_link? @assignment_active.client.contact.full_name
      refute page.has_link? @assignment_inactive.client.contact.full_name
    end
    within '.section-navigation' do
      click_link 'Status: Aktiv'
      click_link 'Inaktiv'
    end
    visit current_url
    within 'tbody' do
      refute page.has_link? @assignment_active.client.contact.full_name
      assert page.has_link? @assignment_inactive.client.contact.full_name
    end
    within '.section-navigation' do
      click_link 'Status: Inaktiv'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert page.has_link? @assignment_active.client.contact.full_name
      refute page.has_link? @assignment_inactive.client.contact.full_name
    end
  end
end
