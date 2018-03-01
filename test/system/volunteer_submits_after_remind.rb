require 'application_system_test_case'

class VolunteerSubmitsAfterRemindTest < ApplicationSystemTestCase
  setup do
    @volunteer = create :volunteer_with_user
    @assignment = create :assignment, volunteer: @volunteer
    create :hour, hourable: @assignment, created_at: 2.days.ago
    @assignment_feedback = create :feedback, feedbackable: @assignment, author: @volunteer.user,
      volunteer: @volunteer
    @group_offer = create :group_offer, volunteers: [@volunteer]
    create :hour, hourable: @group_offer, volunteer: @volunteer, created_at: 2.days.ago
    @group_offer_feedback = create :feedback, feedbackable: @group_offer, author: @volunteer.user,
      volunteer: @volunteer
    login_as @volunteer.user
  end

  test 'volunteer_can_confirm_hours_and_feedbacks_for_their_assignment' do
    visit last_submitted_hours_and_feedbacks_assignment_path(@assignment)
    assert page.has_text? @assignment.client
    assert page.has_text? @assignment_feedback.comments

    click_link 'Bestätigen'

    assert page.has_text? 'Stunden'
    assert page.has_text? 'Feedback'
    assert page.has_text? 'Die Stunden und Feedbacks wurden erfolgreich bestätigt.'
    refute page.has_text? @assignment.client
    refute page.has_text? @assignment_feedback.comments
  end

  test 'volunteer_can_confirm_hours_and_feedbacks_for_their_group_assignment' do
    group_assignment = @group_offer.group_assignments.where(volunteer: @volunteer).last
    visit last_submitted_hours_and_feedbacks_group_assignment_path(group_assignment)
    assert page.has_text? @group_offer.to_label, count: 2
    assert page.has_text? @group_offer_feedback.comments

    click_link 'Bestätigen'

    assert page.has_text? 'Stunden'
    assert page.has_text? 'Feedback'
    assert page.has_text? 'Die Stunden und Feedbacks wurden erfolgreich bestätigt.'
    refute page.has_text? @group_offer.to_label
    refute page.has_text? @group_offer_feedback.comments
  end

  test 'volunteer_can_add_hours_and_feedback_for_their_assignment' do
    visit last_submitted_hours_and_feedbacks_assignment_path(@assignment)
    click_link 'Stunde erfassen'
    select @assignment.to_label, from: 'Einsatz'
    within '#hour_meeting_date_3i' do
      select(Time.zone.today.day)
    end
    within '#hour_meeting_date_2i' do
      select(Time.zone.today.strftime('%B'))
    end
    within '#hour_meeting_date_1i' do
      select(Time.zone.today.year)
    end
    select '2', from: 'Stunden'
    select '15', from: 'Minuten'
    click_button 'Stunde erfassen'

    assert page.has_text? 'Stunde wurde erfolgreich erstellt.'
    assert page.has_text? @assignment.client, count: 3
    assert page.has_text? @assignment_feedback.comments

    click_link 'Feedback erfassen'
    fill_in 'Bemerkungen', with: 'new feedback from volunteer'
    click_button 'Feedback erfassen'

    assert page.has_text? 'Feedback wurde erfolgreich erstellt.'
    assert page.has_text? @assignment.client, count: 4
    assert page.has_text? @assignment_feedback.comments
    assert page.has_text? 'new feedback from volunteer'
  end

  test 'volunteer_can_add_hours_and_feedback_for_their_group_assignment' do
    group_assignment = @group_offer.group_assignments.where(volunteer: @volunteer).last
    visit last_submitted_hours_and_feedbacks_group_assignment_path(group_assignment)
    click_link 'Stunde erfassen'
    select @group_offer.to_label, from: 'Einsatz'
    within '#hour_meeting_date_3i' do
      select(Time.zone.today.day)
    end
    within '#hour_meeting_date_2i' do
      select(Time.zone.today.strftime('%B'))
    end
    within '#hour_meeting_date_1i' do
      select(Time.zone.today.year)
    end
    select '2', from: 'Stunden'
    select '15', from: 'Minuten'
    click_button 'Stunde erfassen'

    assert page.has_text? 'Stunde wurde erfolgreich erstellt.'
    assert page.has_text? @group_offer.to_label, count: 3
    assert page.has_text? @group_offer_feedback.comments

    click_link 'Feedback erfassen'
    fill_in 'Bemerkungen', with: 'new feedback from volunteer'
    click_button 'Feedback erfassen'

    assert page.has_text? 'Feedback wurde erfolgreich erstellt.'
    assert page.has_text? @group_offer.to_label, count: 4
    assert page.has_text? @group_offer_feedback.comments
    assert page.has_text? 'new feedback from volunteer'
  end
end
