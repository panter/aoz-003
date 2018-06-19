require 'application_system_test_case'

class VolunteerSubmitsAfterRemindTest < ApplicationSystemTestCase
  setup do
    @volunteer = create :volunteer
    @assignment = create :assignment, volunteer: @volunteer
    create :hour, hourable: @assignment, created_at: 2.days.ago
    @assignment_feedback = create :feedback, feedbackable: @assignment, author: @volunteer.user,
      volunteer: @volunteer
    @group_offer = create :group_offer
    create :group_assignment, volunteer: @volunteer, group_offer: @group_offer
    create :hour, hourable: @group_offer, volunteer: @volunteer, created_at: 2.days.ago
    @group_offer_feedback = create :feedback, feedbackable: @group_offer, author: @volunteer.user,
      volunteer: @volunteer, comments: 'feedback_volunteer1'
    login_as @volunteer.user
  end

  test 'volunteer_can_confirm_hours_and_feedbacks_for_their_assignment' do
    visit last_submitted_hours_and_feedbacks_assignment_path(@assignment)

    assert_text @assignment.client
    assert_text @assignment_feedback.comments

    check 'Ich verzichte auf die Auszahlung von Spesen.'
    click_on 'Bestätigen'

    assert_equal current_path, hours_and_feedbacks_submitted_assignments_path
    assert_text 'Die Stunden und Feedbacks wurden erfolgreich bestätigt.'

    @volunteer.reload
    assert @volunteer.waive
  end

  test 'volunteer_can_confirm_hours_and_feedbacks_for_their_group_assignment' do
    group_assignment = @group_offer.group_assignments.where(volunteer: @volunteer).last
    visit last_submitted_hours_and_feedbacks_group_assignment_path(group_assignment)

    assert_text group_assignment.to_label
    assert_text @group_offer_feedback.comments

    click_on 'Bestätigen'

    assert_equal current_path, hours_and_feedbacks_submitted_assignments_path
    assert_text 'Die Stunden und Feedbacks wurden erfolgreich bestätigt.'
  end

  test 'volunteer_can_add_hours_and_feedback_for_their_assignment' do
    visit last_submitted_hours_and_feedbacks_assignment_path(@assignment)
    click_link 'Stunden erfassen'
    within '#hour_meeting_date_3i' do
      select Time.zone.today.day
    end
    within '#hour_meeting_date_2i' do
      select I18n.l(Time.zone.today, format: '%B')
    end
    within '#hour_meeting_date_1i' do
      select Time.zone.today.year
    end
    fill_in 'Stunden', with: '2.25'
    click_button 'Stunden erfassen'

    assert_text 'Stunden wurden erfolgreich erfasst.'
    assert_text @assignment.client
    assert_text @assignment_feedback.comments

    click_link 'Feedback erfassen'
    fill_in 'Bemerkungen', with: 'new feedback from volunteer'
    click_button 'Feedback erfassen'

    assert_text 'Feedback wurde erfolgreich erstellt.'
    assert_text @assignment.client
    assert_text @assignment_feedback.comments
    assert_text 'new feedback from volunteer'
  end

  test 'volunteer_can_add_hours_and_feedback_for_their_group_assignment' do
    group_assignment = @group_offer.group_assignments.where(volunteer: @volunteer).last
    visit last_submitted_hours_and_feedbacks_group_assignment_path(group_assignment)
    click_link 'Stunden erfassen'
    select @group_offer.to_label, from: 'Einsatz'
    within '#hour_meeting_date_3i' do
      select Time.zone.today.day
    end
    within '#hour_meeting_date_2i' do
      select I18n.l(Time.zone.today, format: '%B')
    end
    within '#hour_meeting_date_1i' do
      select Time.zone.today.year
    end
    fill_in 'Stunden', with: '2.25'
    click_button 'Stunden erfassen'

    assert_text 'Stunden wurden erfolgreich erfasst.'
    assert_text group_assignment.to_label
    assert_text @group_offer_feedback.comments

    click_link 'Feedback erfassen'
    fill_in 'Bemerkungen', with: 'new feedback from volunteer'
    click_button 'Feedback erfassen'

    assert_text 'Feedback wurde erfolgreich erstellt.'
    assert_text group_assignment.to_label
    assert_text @group_offer_feedback.comments
    assert_text 'new feedback from volunteer'
  end

  test 'volunteer can see only own hours and feedbacks of group assignment' do
    @group_assignment1 = @group_offer.group_assignments.where(volunteer: @volunteer).last
    @hour_volunteer1 = create :hour, volunteer: @volunteer, hourable: @group_offer,
      comments: 'hour_volunteer1'

    @volunteer2 = create :volunteer
    @group_assignment2 = @group_offer.group_assignments.where(volunteer: @volunteer2).last
    @hour_volunteer2 = create :hour, volunteer: @volunteer2, hourable: @group_offer,
      comments: 'hour_volunteer2'
    @group_offer_feedback2 = create :feedback, feedbackable: @group_offer, author: @volunteer2.user,
      volunteer: @volunteer2, comments: 'feedback_volunteer2'

    visit last_submitted_hours_and_feedbacks_group_assignment_path(@group_assignment1)

    assert_text 'hour_volunteer1'
    assert_text 'feedback_volunteer1'
    refute_text 'hour_volunteer2'
    refute_text 'feedback_volunteer2'
  end
end
