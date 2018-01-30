require 'application_system_test_case'

class GroupOfferTerminationsTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @department_manager = create :department_manager
    @department = @department_manager.department.first
    @group_offer = create :group_offer, department: @department, creator: @department_manager
    @group_assignment1 = create :group_assignment, group_offer: @group_offer, period_start: 6.months.ago,
      period_end: nil
    @group_assignment2 = create :group_assignment, group_offer: @group_offer, period_start: 5.months.ago,
      period_end: nil, responsible: true
  end

  test 'initiate_termination_form_is_disabled_when_has_running_group_asignments' do
    login_as @superadmin
    visit group_offers_path
    click_link 'Beenden', href: initiate_termination_group_offer_path(@group_offer)
    assert page.has_text? 'Noch nicht beendete Gruppeneinsätze'
    assert page.has_text? "#{@group_assignment1.volunteer.full_name} Member #{I18n.l(@group_assignment1.period_start)}"
    assert page.has_text? "#{@group_assignment2.volunteer.full_name} Responsible #{I18n.l(@group_assignment2.period_start)}"
    assert page.has_text? 'Um das Gruppenangebot zu beenden, müssen erst alle zugehörigen Gruppeneinsätze beendet sein.'
    assert page.has_field? 'Period end', disabled: true
    assert page.has_button? 'Gruppenangebots Ende setzen', disabled: true
  end
end
