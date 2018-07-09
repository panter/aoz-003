require 'application_system_test_case'

class VolunteerSubmitsAfterRemindTest < ApplicationSystemTestCase
  setup do
    @assignment = create :assignment
    @volunteer = @assignment.volunteer
    create :hour, hourable: @assignment, created_at: 2.days.ago
    @assignment_feedback = create :feedback, feedbackable: @assignment, author: @volunteer.user,
      volunteer: @volunteer
    @group_offer = create :group_offer
    @group_assignment = create :group_assignment, volunteer: @volunteer, group_offer: @group_offer
    create :hour, hourable: @group_offer, volunteer: @volunteer, created_at: 2.days.ago
    @group_offer_feedback = create :feedback, feedbackable: @group_offer, author: @volunteer.user,
      volunteer: @volunteer, comments: 'feedback_volunteer1'
    login_as @volunteer.user
  end

  test 'last_submitted_hours_and_feedbacks_form_is_autosaved' do
    @volunteer.update(waive: false, iban: nil, bank: nil)
    visit last_submitted_hours_and_feedbacks_assignment_path(@assignment)

    fill_field_char_by_char_and_wait_for_ajax('IBAN', 'CH12345')
    @volunteer.reload
    assert_equal 'CH12345', @volunteer.iban

    fill_field_char_by_char_and_wait_for_ajax('Bank', 'Name of the bank')
    @volunteer.reload
    assert_equal 'Name of the bank', @volunteer.bank

    visit last_submitted_hours_and_feedbacks_assignment_path(@assignment)
    assert page.has_field? 'IBAN', with: 'CH12345'
    assert page.has_field? 'Name der Bank', with: 'Name of the bank'

    check 'Ich verzichte auf die Auszahlung von Spesen.'
    wait_for_ajax
    @volunteer.reload
    assert @volunteer.waive

    visit last_submitted_hours_and_feedbacks_assignment_path(@assignment)
    assert page.has_field? 'Ich verzichte auf die Auszahlung von Spesen.', checked: true
    refute page.has_field? 'IBAN'
    refute page.has_field? 'Name der Bank'
  end

  test 'volunteer_can_confirm_hours_and_feedbacks_for_their_assignment' do
    visit last_submitted_hours_and_feedbacks_assignment_path(@assignment)

    assert_text @assignment.client
    assert_text @assignment_feedback.comments

    check 'Ich verzichte auf die Auszahlung von Spesen.'
    click_on 'Bestätigen'

    assert_equal current_path, hours_and_feedbacks_submitted_assignments_path
    assert_text 'Die Stunden und Halbjahres-Rapporte wurden erfolgreich bestätigt.'

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
    assert_text 'Die Stunden und Halbjahres-Rapporte wurden erfolgreich bestätigt.'
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

    click_link 'Halbjahres-Rapport erfassen'
    fill_in 'Bemerkungen', with: 'new feedback from volunteer'
    click_button 'Halbjahres-Rapport erfassen'

    assert_text 'Halbjahres-Rapport wurde erfolgreich erstellt.'
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

    click_link 'Halbjahres-Rapport erfassen'
    fill_in 'Bemerkungen', with: 'new feedback from volunteer'
    click_button 'Halbjahres-Rapport erfassen'

    assert_text 'Halbjahres-Rapport wurde erfolgreich erstellt.'
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

  test 'volunteer_can_edit_feedback_on_last_submitted_hours_and_feedbacks_path' do
    login_as @assignment_feedback.volunteer.user
    visit last_submitted_hours_and_feedbacks_assignment_path(@assignment_feedback.feedbackable)

    click_link 'Bearbeiten', match_polymorph_path(
      [@assignment_feedback.volunteer, @assignment_feedback.feedbackable, @assignment_feedback]
    )

    # assert the redirect back to the previous page works
    fill_in 'Was konnte in den letzten Monaten erreicht werden?', with: 'some_different_goal_text'
    click_button 'Halbjahres-Rapport aktualisieren'
    assert page.has_text? 'Halbjahres-Rapport wurde erfolgreich geändert.'
    assert page.has_text? 'Zuletzt übermittelte Stunden und Halbjahres-Rapporte'
  end

  test 'superadmin_clicks_submit_on_lshaf_form_ads_submitted_at_and_submitted_by' do
    # Assignment
    login_as @assignment_feedback.feedbackable.creator
    visit last_submitted_hours_and_feedbacks_assignment_path(@assignment_feedback.feedbackable)
    click_button 'Bestätigen'
    @assignment_feedback.feedbackable.reload
    assert_equal @assignment_feedback.feedbackable.creator, @assignment_feedback.feedbackable.submitted_by
    # GroupAssignment
    login_as @group_assignment.creator
    visit last_submitted_hours_and_feedbacks_group_assignment_path(@group_assignment)
    click_button 'Bestätigen'
    @group_assignment.reload
    assert_equal @group_assignment.creator, @group_assignment.submitted_by
  end

  test 'volunteer_does_not_see_bestaetigen_if_superadmin_allready_did' do
    # Assignment
    feedback_submitter = @assignment_feedback.feedbackable.creator
    @assignment_feedback.feedbackable.update(submit_feedback: feedback_submitter)
    login_as @assignment_feedback.volunteer.user
    visit last_submitted_hours_and_feedbacks_assignment_path(@assignment_feedback.feedbackable)
    assert page.has_text? 'Bestätigt am ' \
      "#{I18n.l(@assignment_feedback.feedbackable.submitted_at.to_date)} durch " \
      "#{feedback_submitter.full_name} - #{feedback_submitter.email}"
    refute page.has_button? 'Bestätigen'
    # GroupAssignment
    feedback_submitter = @group_assignment.creator
    @group_assignment.update(submit_feedback: feedback_submitter)
    login_as @group_assignment.volunteer.user
    visit last_submitted_hours_and_feedbacks_group_assignment_path(@group_assignment)
    assert page.has_text? 'Bestätigt am ' \
      "#{I18n.l(@group_assignment.submitted_at.to_date)} durch " \
      "#{feedback_submitter.full_name} - #{feedback_submitter.email}"
    refute page.has_button? 'Bestätigen'
  end
end
