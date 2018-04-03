require 'application_system_test_case'

class AssignmentFiltersTest < ApplicationSystemTestCase
  def setup
    @assignment_active = create :assignment, :active
    @assignment_inactive = create :assignment, :inactive

    login_as create(:user)
    visit assignments_path
  end

  test 'filter by activity' do
    within 'tbody' do
      assert_text 'Aktiv'
      refute_text 'Inaktiv'
    end

    within '.section-navigation' do
      click_link 'Status: Aktiv'
      click_link 'Alle'
    end

    within 'tbody' do
      assert_text 'Aktiv'
      assert_text 'Inaktiv'
    end

    within '.section-navigation' do
      click_link exact_text: 'Status'
      click_link 'Inaktiv'
    end

    within 'tbody' do
      refute_text 'Aktiv'
      assert_text 'Inaktiv'
    end
  end
end
