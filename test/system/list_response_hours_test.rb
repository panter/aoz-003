require 'application_system_test_case'

class ListResponseHoursTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @assignment_pendent = create(:assignment)
    @assignment_hour_pendent = create :hour, volunteer: @assignment_pendent.volunteer,
      hourable: @assignment_pendent, hours: Faker::Number.between(1, 8),
      minutes: [0, 15, 30, 45].sample
    @assignment_done = create(:assignment)
    @assignment_hour_done = create :hour, hourable: @assignment_done,
      volunteer: @assignment_done.volunteer, marked_done_by: @superadmin,
      hours: Faker::Number.between(1, 8),
      minutes: [0, 15, 30, 45].sample

    @group_assignment_pendent = create :group_assignment
    @group_assignment_hour_pendent = create :hour, volunteer: @group_assignment_pendent.volunteer,
      hourable: @group_assignment_pendent.group_offer, hours: Faker::Number.between(1, 8),
      minutes: [0, 15, 30, 45].sample
    @group_assignment_done = create :group_assignment
    @group_assignment_hour_done = create :hour, hourable: @group_assignment_done.group_offer,
      volunteer: @group_assignment_done.volunteer, marked_done_by: @superadmin,
      hours: Faker::Number.between(1, 8),
      minutes: [0, 15, 30, 45].sample
    login_as @superadmin
    visit reminder_mailings_path
  end

  test 'hours_list_contains_only_relevant_records' do
    click_link 'Stunden Eingang', href: list_responses_hours_path(
      q: { marked_done_by_id_null: 'true', s: 'updated_at asc' }
    )
    assert page.has_link? @assignment_pendent.volunteer.contact.full_name
    assert page.has_link? @assignment_hour_pendent.hourable.to_label
    assert page.has_text?(
      (60.0 / @assignment_hour_pendent.minutes * 0.1) + @assignment_hour_pendent.hours
    )
    assert page.has_link? @group_assignment_pendent.volunteer.contact.full_name
    assert page.has_link? @group_assignment_hour_pendent.hourable.to_label
    assert page.has_text?(
      (60.0 / @group_assignment_hour_pendent.minutes * 0.1) + @group_assignment_hour_pendent.hours
    )

    # marked done shoudn't be displayed
    refute page.has_link? @assignment_done.volunteer.contact.full_name
    refute page.has_link? @assignment_hour_done.hourable.to_label
    refute page.has_link? @group_assignment_done.volunteer.contact.full_name
    refute page.has_link? @group_assignment_hour_done.hourable.to_label
  end

  test 'hours list without filter shows marked done feedback' do
    click_link 'Stunden Eingang', href: list_responses_hours_path(
      q: { marked_done_by_id_null: 'true', s: 'updated_at asc' }
    )
    click_link 'Filter aufheben'
    visit current_url
    # marked done shoud now be displayed
    assert page.has_link? @assignment_done.volunteer.contact.full_name
    assert page.has_link? @assignment_hour_done.hourable.to_label
    assert page.has_text?(
      (60.0 / @assignment_hour_done.minutes * 0.1) + @assignment_hour_done.hours
    )
    assert page.has_link? @group_assignment_done.volunteer.contact.full_name
    assert page.has_link? @group_assignment_hour_done.hourable.to_label
    assert page.has_text?(
      (60.0 / @group_assignment_hour_done.minutes * 0.1) + @group_assignment_hour_done.hours
    )
  end

  test 'hours list with filter erledigt shows only marked done' do
    click_link 'Stunden Eingang', href: list_responses_hours_path(
      q: { marked_done_by_id_null: 'true', s: 'updated_at asc' }
    )
    click_link 'Überprüfung: Nicht Erledigt'
    click_link 'Erledigt', href: list_responses_hours_path(
      q: { marked_done_by_id_not_null: 'true', s: 'updated_at asc' }
    )
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
    click_link 'Stunden Eingang', href: list_responses_hours_path(
      q: { marked_done_by_id_null: 'true', s: 'updated_at asc' }
    )
    click_link 'Erledigt', href: polymorphic_path(
      [@assignment_pendent.volunteer, @assignment_pendent, @assignment_hour_pendent],
      action: :mark_as_done
    )
    assert page.has_text? 'Stunden als erledigt markiert.'
    refute page.has_link? @assignment_pendent.volunteer.contact.full_name
    refute page.has_link? @assignment_hour_pendent.hourable.to_label

    click_link 'Filter aufheben'
    visit current_url
    assert page.has_text? 'Ereledigt markiert durch: '
    refute page.has_link? 'Erledigt', href: polymorphic_path(
      [@assignment_pendent.volunteer, @assignment_pendent, @assignment_hour_pendent],
      action: :mark_as_done
    )

    click_link 'Erledigt', href: polymorphic_path(
      [@group_assignment_pendent.volunteer, @group_assignment_pendent.group_offer,
       @group_assignment_hour_pendent], action: :mark_as_done
    )
    assert page.has_text? 'Stunden als erledigt markiert.'
    click_link 'Filter aufheben'
    visit current_url
    refute page.has_link? 'Erledigt', href: polymorphic_path(
      [@group_assignment_pendent.volunteer, @group_assignment_pendent.group_offer,
       @group_assignment_hour_pendent], action: :mark_as_done
    )
  end
end
