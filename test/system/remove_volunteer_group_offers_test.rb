require 'application_system_test_case'

class RemoveVolunteerGroupOffersTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @group_offer = create :group_offer
    @ga1 = create :group_assignment, group_offer: @group_offer, period_start: 3.months.ago,
      responsible: true
    @ga2 = create :group_assignment, group_offer: @group_offer, period_start: 5.months.ago,
      responsible: false
  end

  test 'group_assignments_are_listed_in_group_offer_show' do
    login_as @superadmin
    visit group_offer_path(@group_offer)
    within '.assignments-table' do
      assert page.has_text? "#{@ga1.volunteer.contact.full_name} "\
        "#{@ga1.responsible ? 'Verantwortliche/r' : 'Mitglied'} #{I18n.l(@ga1.period_start)}"
      assert page.has_link? 'Bearbeiten',
        href: edit_group_assignment_path(@ga1, redirect_to: group_offer_path(@group_offer))
      assert page.has_link? 'Heute beenden',
        href: set_end_today_group_assignment_path(@ga1, redirect_to: group_offer_path(@group_offer))
      refute page.has_link? 'Beendigungsformular an Freiwillige/n',
        href: polymorphic_path([@ga1, ReminderMailing], action: :new_termination)
      assert page.has_text? "#{@ga2.volunteer.contact.full_name} "\
        "#{@ga2.responsible ? 'Verantwortliche/r' : 'Mitglied'} #{I18n.l(@ga2.period_start)}"
      assert page.has_link? 'Bearbeiten',
        href: edit_group_assignment_path(@ga2, redirect_to: group_offer_path(@group_offer))
      assert page.has_link? 'Heute beenden',
        href: set_end_today_group_assignment_path(@ga2, redirect_to: group_offer_path(@group_offer))
    end
  end

  test 'setting_period_end_with_today_shortcut' do
    login_as @superadmin
    visit group_offer_path(@group_offer)
    click_link 'Heute beenden',
      href: set_end_today_group_assignment_path(@ga1, redirect_to: group_offer_path(@group_offer))
    assert page.has_text? 'Einsatzende wurde erfolgreich gesetzt.'
    @ga1.reload
    visit group_offer_path(@group_offer)
    within '.assignments-table' do
      assert page.has_text? "#{@ga1.volunteer.contact.full_name} "\
        "#{@ga1.responsible ? 'Verantwortliche/r' : 'Mitglied'} #{I18n.l(@ga1.period_start)}"\
        " #{I18n.l(@ga1.period_end)} "
      refute page.has_link? 'Heute beenden',
        href: set_end_today_group_assignment_path(@ga1, redirect_to: group_offer_path(@group_offer))
      assert page.has_link? 'Beendigungsformular an Freiwillige/n',
        href: polymorphic_path([@ga1, ReminderMailing], action: :new_termination)
    end
  end

  test 'changing_volunteer_to_member_works' do
    login_as @superadmin
    visit group_offer_path(@group_offer)
    within '.assignments-table' do
      assert page.has_text? 'Verantwortliche/r'
      click_link 'Bearbeiten',
        href: edit_group_assignment_path(@ga1, redirect_to: group_offer_path(@group_offer))
    end
    uncheck 'Verantwortliche/r'
    page.find_all('input[type="submit"]').first.click
    assert page.has_text? 'Begleitung wurde erfolgreich geändert.'
    within '.assignments-table' do
      refute page.has_text? 'Verantwortliche/r'
    end
  end
end
