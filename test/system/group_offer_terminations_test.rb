require 'application_system_test_case'

class GroupOfferTerminationsTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @department_manager = create :department_manager
    @department = @department_manager.department.first
    @group_offer = create :group_offer, department: @department, creator: @department_manager
    @group_assignment1 = create :group_assignment, group_offer: @group_offer,
      period_start: 6.months.ago, period_end: nil
    @group_assignment2 = create :group_assignment, group_offer: @group_offer,
      period_start: 5.months.ago, period_end: nil, responsible: true
  end

  test 'initiate_termination_form_is_disabled_when_has_running_group_asignments' do
    login_as @superadmin
    visit group_offers_path
    click_link 'Beenden', href: initiate_termination_group_offer_path(@group_offer)
    assert page.has_text? 'Noch nicht beendete Gruppeneinsätze'
    assert page.has_text? "#{@group_assignment1.volunteer.full_name} "\
      "Mitglied #{I18n.l(@group_assignment1.period_start)}"
    assert page.has_text? "#{@group_assignment2.volunteer.full_name} "\
      "Verantwortliche/r #{I18n.l(@group_assignment2.period_start)}"
    assert page.has_text? 'Um das Gruppenangebot zu beenden, müssen erst alle zugehörigen '\
      'Gruppeneinsätze beendet sein.'
    assert page.has_field? 'Angebotsenddatum', disabled: true
    assert page.has_button? 'Gruppenangebots Ende setzen', disabled: true
  end

  test 'all_group_assignments_can_get_there_period_end_set_in_one_go' do
    login_as @superadmin
    visit initiate_termination_group_offer_path(@group_offer)
    assert page.has_field? id: 'group_offer_group_assignments_attributes_0_period_end',
      with: Time.zone.today.to_s
    click_button 'Jetzt alle Einsätze auf Enddatum beenden'
    assert page.has_text? 'Gruppeneinsätze wurden beendet.'
    assert page.has_field? 'Angebotsenddatum', with: Time.zone.today.to_s
    click_button 'Gruppenangebots Ende setzen'
    assert page.has_text? 'Gruppenangebots Beendigung erfolgreich eingeleitet.'
  end

  test 'setting_period_end_to_group_assignment_single_works' do
    login_as @superadmin
    visit initiate_termination_group_offer_path(@group_offer)
    click_link 'Heute beenden', href: set_end_today_group_assignment_path(@group_assignment1,
      redirect_to: :initiate_termination)
    assert page.has_text? 'Einsatzende wurde erfolgreich gesetzt.'
    assert page.has_text? 'Noch nicht beendete Gruppeneinsätze'
    refute page.has_text? "#{@group_assignment1.volunteer.full_name} "\
      "Member #{I18n.l(@group_assignment1.period_start)}"
    assert page.has_text? "#{@group_assignment2.volunteer.full_name} "\
      "Verantwortliche/r #{I18n.l(@group_assignment2.period_start)}"
    click_link 'Bearbeiten', href: edit_group_assignment_path(@group_assignment2,
      redirect_to: :initiate_termination)
    fill_in id: 'group_assignment_period_end', with: Time.zone.today.to_s
    click_button 'Begleitung aktualisieren'
    assert page.has_text? 'Einsatzende wurde erfolgreich gesetzt.'
    refute page.has_text? 'Noch nicht beendete Gruppeneinsätze'
    click_button 'Gruppenangebots Ende setzen'
    assert page.has_text? 'Gruppenangebots Beendigung erfolgreich eingeleitet.'
  end
end
