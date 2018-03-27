require 'application_system_test_case'

class ListResponseHoursTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @assignment_pendent = create(:assignment)
    @assignment_hour_pendent = create :hour, volunteer: @assignment_pendent.volunteer,
      hourable: @assignment_pendent, hours: rand(1..8)
    @assignment_done = create(:assignment)
    @assignment_hour_done = create :hour, hourable: @assignment_done,
      volunteer: @assignment_done.volunteer, reviewer: @superadmin,
      hours: rand(1..8)

    @group_assignment_pendent = create :group_assignment
    @group_assignment_hour_pendent = create :hour, volunteer: @group_assignment_pendent.volunteer,
      hourable: @group_assignment_pendent.group_offer, hours: rand(1..8)
    @group_assignment_done = create :group_assignment
    @group_assignment_hour_done = create :hour, hourable: @group_assignment_done.group_offer,
      volunteer: @group_assignment_done.volunteer, reviewer: @superadmin,
      hours: rand(1..8)
    login_as @superadmin
    visit reminder_mailings_path
  end

  test 'hours_list_contains_only_relevant_records' do
    click_link 'Stunden Eingang'
    assert page.has_link? @assignment_pendent.volunteer.contact.full_name
    assert page.has_link? @assignment_hour_pendent.hourable.to_label
    assert page.has_text? @assignment_hour_pendent.hours
    assert page.has_link? @group_assignment_pendent.volunteer.contact.full_name
    assert page.has_link? @group_assignment_hour_pendent.hourable.to_label
    assert page.has_text? @group_assignment_hour_pendent.hours

    # marked done shoudn't be displayed
    refute page.has_link? @assignment_done.volunteer.contact.full_name
    refute page.has_link? @assignment_hour_done.hourable.to_label
    refute page.has_link? @group_assignment_done.volunteer.contact.full_name
    refute page.has_link? @group_assignment_hour_done.hourable.to_label
  end

  test 'hours list without filter shows marked done feedback' do
    click_link 'Stunden Eingang'
    click_link 'Filter aufheben'
    visit current_url
    # marked done shoud now be displayed
    assert page.has_link? @assignment_done.volunteer.contact.full_name
    assert page.has_link? @assignment_hour_done.hourable.to_label
    assert page.has_text? @assignment_hour_pendent.hours
    assert page.has_link? @group_assignment_done.volunteer.contact.full_name
    assert page.has_link? @group_assignment_hour_done.hourable.to_label
    assert page.has_text? @assignment_hour_done.hours

  end

  test 'hours list with filter angechaut shows only marked done' do
    click_link 'Stunden Eingang'
    click_link 'Geprüft: Ungesehen'
    within 'li.dropdown.open' do
      click_link 'Angeschaut'
    end
    visit current_url
    # not marked done should now be filtered
    refute page.has_link? @assignment_pendent.volunteer.contact.full_name
    refute page.has_link? @assignment_hour_pendent.hourable.to_label
    refute page.has_link? @group_assignment_pendent.volunteer.contact.full_name
    refute page.has_link? @group_assignment_hour_pendent.hourable.to_label

    # marked done shoud be displayed
    assert page.has_link? @assignment_done.volunteer.contact.full_name
    assert page.has_link? @assignment_hour_done.hourable.to_label
    assert page.has_link? @group_assignment_done.volunteer.contact.full_name
    assert page.has_link? @group_assignment_hour_done.hourable.to_label
  end

  test 'marking_hours_done_works' do
    click_link 'Stunden Eingang'
    within 'tbody' do
      click_link 'Angeschaut', href: /.*\/volunteers\/#{@assignment_pendent.volunteer.id}\/
        assignments\/#{@assignment_pendent.id}\/hours
        \/#{@assignment_hour_pendent.id}\/.*/x
    end
    assert page.has_text? 'Stunden als angeschaut markiert.'
    refute page.has_link? @assignment_pendent.volunteer.contact.full_name
    refute page.has_link? @assignment_hour_pendent.hourable.to_label
    within 'tbody' do
      click_link 'Angeschaut', href: /.*\/volunteers\/#{@group_assignment_pendent.volunteer.id}\/
        group_offers\/#{@group_assignment_pendent.group_offer.id}\/hours
        \/#{@group_assignment_hour_pendent.id}\/.*/x
    end
    assert page.has_text? 'Stunden als angeschaut markiert.'
  end

  test 'hour_waive_filter_works' do
    assignment_waive = create(:assignment, volunteer: create(:volunteer_with_user, waive: true))
    assignment_hour_waive = create :hour, hourable: assignment_waive,
      volunteer: assignment_waive.volunteer, hours: rand(1..8)
    click_link 'Stunden Eingang'
    click_link 'Spesen'
    click_link 'Verzichtet'
    visit current_url

    assert page.has_link? assignment_waive.volunteer.contact.full_name
    assert page.has_link? assignment_hour_waive.hourable.to_label
    assert page.has_text? assignment_hour_waive.hours

    refute page.has_link? @assignment_pendent.volunteer.contact.full_name
    refute page.has_link? @assignment_hour_pendent.hourable.to_label
    refute page.has_link? @group_assignment_pendent.volunteer.contact.full_name
    refute page.has_link? @group_assignment_hour_pendent.hourable.to_label

    click_link 'Spesen: Verzichtet'
    click_link 'Auszahlung'
    visit current_url

    refute page.has_link? assignment_waive.volunteer.contact.full_name
    refute page.has_link? assignment_hour_waive.hourable.to_label

    assert page.has_link? @assignment_pendent.volunteer.contact.full_name
    assert page.has_link? @assignment_hour_pendent.hourable.to_label
    assert page.has_link? @group_assignment_pendent.volunteer.contact.full_name
    assert page.has_link? @group_assignment_hour_pendent.hourable.to_label
  end
end
