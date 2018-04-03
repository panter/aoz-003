require 'application_system_test_case'

class TerminateVolunteersTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user
    @group_offer = create :group_offer, creator: @superadmin

    ### ASSIGNMENTS SETUP
    # active
    @client = create :client, user: @superadmin
    @volunteer_aa = create :volunteer_with_user
    @active_assignment = create :assignment, volunteer: @volunteer_aa, client: @client,
      period_start: 10.weeks.ago, period_end: nil, creator: @superadmin
    @hour = create :hour, volunteer: @volunteer_aa, hourable: @active_assignment
    @feedback = create :feedback, volunteer: @volunteer_aa, feedbackable: @active_assignment,
      author: @volunteer_aa.user

    # ended/unsubmitted Assignment
    @volunteer_ua = create :volunteer_with_user
    @unsubmitted_assignment = create :assignment, volunteer: @volunteer_ua, client: @client,
      period_start: 10.weeks.ago, period_end: 2.days.ago, creator: @superadmin,
      period_end_set_by: @superadmin

    # submitted
    @volunteer_sa = create :volunteer_with_user
    @submitted_assignment = create :assignment, volunteer: @volunteer_sa,
      period_start: 3.weeks.ago, period_end: 2.days.ago,
      termination_submitted_at: 2.days.ago, termination_submitted_by: @volunteer_sa.user,
      period_end_set_by: @superadmin

    ### GROUPASSIGNMENTS SETUP
    # active
    @active_group_assignment = create :group_assignment, volunteer: @volunteer_aa, group_offer: @group_offer,
      period_start: 20.days.ago, period_end: nil, period_end_set_by: @superadmin
    @hour = create :hour, volunteer: @volunteer_aa, hourable: @group_offer, hours: 2
    @feedback = create :feedback, volunteer: @volunteer_aa, author: @volunteer_aa.user,
      feedbackable: @group_offer

    # ended/unsubmitted
    @unsubmitted_group_assignment = create :group_assignment, group_offer: @group_offer, volunteer: @volunteer_ua,
      period_start: 3.weeks.ago, period_end: 2.days.ago, period_end_set_by: @superadmin

    # submitted
    @submitted_group_assignment = create :group_assignment, group_offer: @group_offer, volunteer: @volunteer_sa,
      period_start: 3.weeks.ago, period_end: 2.days.ago,
      termination_submitted_at: 2.days.ago, termination_submitted_by: @volunteer_sa.user,
      period_end_set_by: @superadmin

    login_as @superadmin
  end

  test 'Volunteer with active assignments can not be terminated' do
    visit volunteer_path(@volunteer_aa)
    first(:link, 'Beenden').click

    assert page.has_text?
      'Beenden fehlgeschlagen. Freiwillige/r kann nicht beendet werden, solange noch laufende Einsätze existieren.'
    assert page.has_link? 'Begleitung bearbeiten'

    @active_assignment.update(period_end: 2.days.ago)
    @volunteer_aa.reload
    visit current_url
    first(:link, 'Beenden').click
    assert page.has_text?
      'Beenden fehlgeschlagen. Freiwillige/r kann nicht beendet werden, solange noch laufende Einsätze existieren.'
    assert page.has_link? 'Begleitung bearbeiten'

    @active_group_assignment.update(period_end: 2.days.ago)
    @volunteer_aa.reload
    visit current_url
    first(:link, 'Beenden').click
    assert page.has_text?
      'Beenden fehlgeschlagen. Freiwillige/r kann nicht beendet werden, solange noch laufende Einsätze existieren.'
    assert page.has_link? 'Begleitung bearbeiten'
  end

  test 'Volunteer with ended but not submitted assignments can not be terminated' do
    visit volunteer_path(@volunteer_ua)
    first(:link, 'Beenden').click

    assert page.has_text?
      'Beenden fehlgeschlagen. Freiwillige/r kann nicht beendet werden, solange noch laufende Einsätze existieren.'

    @unsubmitted_assignment.update(termination_submitted_at: 2.days.ago,
      termination_submitted_by: @volunteer_sa.user, period_end_set_by: @superadmin)
    @volunteer_ua.reload
    visit current_url
    first(:link, 'Beenden').click
    assert page.has_text?
      'Beenden fehlgeschlagen. Freiwillige/r kann nicht beendet werden, solange noch laufende Einsätze existieren.'
    assert page.has_link? 'Begleitung bearbeiten'

    @unsubmitted_group_assignment.update(termination_submitted_at: 2.days.ago,
      termination_submitted_by: @volunteer_ua.user, period_end_set_by: @superadmin)
    @volunteer_ua.reload
    visit current_url
    first(:link, 'Beenden').click
    assert page.has_text?
      'Beenden fehlgeschlagen. Freiwillige/r kann nicht beendet werden, solange noch laufende Einsätze existieren.'
    assert page.has_link? 'Begleitung bearbeiten'
  end

  test 'Volunteer with ended, submitted but not verified assignments can not be terminated' do
    visit volunteer_path(@volunteer_sa)
    first(:link, 'Beenden').click

    assert page.has_text?
      'Beenden fehlgeschlagen. Freiwillige/r kann nicht beendet werden, solange noch laufende Einsätze existieren.'

    @submitted_assignment.update(termination_submitted_at: 2.days.ago,
      termination_submitted_by: @volunteer_sa.user, period_end_set_by: @superadmin,
      termination_verified_at: 2.days.ago, termination_verified_by: @superadmin)
    @volunteer_sa.reload
    visit current_url
    first(:link, 'Beenden').click
    assert page.has_text?
      'Beenden fehlgeschlagen. Freiwillige/r kann nicht beendet werden, solange noch laufende Einsätze existieren.'
    assert page.has_link? 'Begleitung bearbeiten'

    @submitted_group_assignment.update(termination_submitted_at: 2.days.ago,
      termination_submitted_by: @volunteer_sa.user, period_end_set_by: @superadmin,
      termination_verified_at: 2.days.ago, termination_verified_by: @superadmin)
    @volunteer_sa.reload
    visit current_url
    first(:link, 'Beenden').click
    assert page.has_text? 'Freiwillige/r wurde erfolgreich beendet.'
  end
end
