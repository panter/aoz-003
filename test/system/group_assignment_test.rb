require 'application_system_test_case'

class GroupAssignmentTest < ApplicationSystemTestCase
  setup do
    @department = create :department
    @department_manager = create :department_manager, department: [@department]
    @another_department_manager = create :department_manager, department: [@department]
    @department_manager_without_department = create :department_manager_without_department

    @group_offer = create :group_offer, creator: @another_department_manager,
      department: @another_department_manager.department.first
    @group_assignment = create :group_assignment, group_offer: @group_offer
  end

  test 'department_manager without department has read-only access' do
    3.times { create :terminated_group_assignment, group_offer: create(:group_offer) }
    login_as @department_manager_without_department

    visit group_offers_path
    assert page.has_link? 'Beendete Einsätze'

    click_link 'Beendete Einsätze'
    assert page.has_text? 'Beendete Gruppeneinsätze'

    click_link 'Filter aufheben'

    GroupAssignment.ended.each do |assignment|
      assert page.has_css? "tr##{dom_id assignment}"
    end

    assert page.has_link? 'Anzeigen'
    refute page.has_link? 'Bearbeiten'
    refute page.has_link? 'Beendigungsformular'
    refute page.has_link? 'Freiwillige/n beenden'

    visit group_offer_path @group_offer
    within '.table-responsive.assignments-table' do
      refute page.has_link? 'Bearbeiten'
    end
  end

  test 'department_manager can edit all group_assignments from her department' do
    login_as @department_manager
    visit edit_group_offer_path @group_offer

    within '.table-responsive.assignments-table' do
      assert page.has_link? 'Bearbeiten'

      click_link 'Bearbeiten'
    end

    assert page.has_text? 'Gruppenangebots Einsatz bearbeiten'

    fill_in 'Bemerkungen', with: 'Test'
    click_button 'Begleitung aktualisieren', match: :first
    assert page.has_text? 'Begleitung wurde erfolgreich geändert.'
  end
end
