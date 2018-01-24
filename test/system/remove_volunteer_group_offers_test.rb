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
        "#{@ga1.responsible ? 'Responsible' : 'Member'} #{I18n.l(@ga1.period_start)}"
      assert page.has_link? 'Bearbeiten', href: edit_group_assignment_path(@ga1)
      assert page.has_link? 'Heute beenden', href: set_end_today_group_assignment_path(@ga1)
      refute page.has_link? 'Beendigungsformular an Freiwillige/n',
        href: polymorphic_path([@ga1, ReminderMailing], action: :new_termination)
      assert page.has_text? "#{@ga2.volunteer.contact.full_name} "\
        "#{@ga2.responsible ? 'Responsible' : 'Member'} #{I18n.l(@ga2.period_start)}"
      assert page.has_link? 'Bearbeiten', href: edit_group_assignment_path(@ga2)
      assert page.has_link? 'Heute beenden', href: set_end_today_group_assignment_path(@ga2)
    end
  end

  test 'setting_period_end_with_today_shortcut' do
    login_as @superadmin
    visit group_offer_path(@group_offer)
    click_link 'Heute beenden', href: set_end_today_group_assignment_path(@ga1)
    assert page.has_text? 'Einsatzende erfolgreich gesetzt.'
    @ga1.reload
    within '.assignments-table' do
      assert page.has_text? "#{@ga1.volunteer.contact.full_name} "\
        "#{@ga1.responsible ? 'Responsible' : 'Member'} #{I18n.l(@ga1.period_start)}"\
        " #{I18n.l(@ga1.period_end)} "
      refute page.has_link? 'Heute beenden', href: set_end_today_group_assignment_path(@ga1)
      assert page.has_link? 'Beendigungsformular an Freiwillige/n',
        href: polymorphic_path([@ga1, ReminderMailing], action: :new_termination)
    end
    within '.log-table' do
      assert page.has_text? "#{@ga1.volunteer.contact.full_name} "\
        "#{@ga1.responsible ? 'Responsible' : 'Member'} #{I18n.l(@ga1.period_start)} "
      assert page.has_text? I18n.l(@ga1.group_assignment_logs.first.created_at)
      refute page.has_text? I18n.l(@ga1.period_end)
    end
  end

  test 'changing_volunteer_to_member_works' do
    login_as @superadmin
    visit group_offer_path(@group_offer)
    within '.assignments-table' do
      assert page.has_text? 'Responsible'
      click_link 'Bearbeiten', href: edit_group_assignment_path(@ga1)
    end
    uncheck 'Responsible'
    click_button 'Update Group assignment'
    assert page.has_text? 'Group assignment was successfully updated.'
    within '.assignments-table' do
      refute page.has_text? 'Responsible'
    end
  end
end
