require 'application_system_test_case'

class GroupAssignmentTerminatesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @volunteer = create :volunteer, salutation: 'mrs'
    @group_offer = create :group_offer, creator: @superadmin
    @group_assignment = create :group_assignment, volunteer: @volunteer, group_offer: @group_offer,
      period_start: 20.days.ago, period_end: 10.days.ago, period_end_set_by: @superadmin
    @hour = create :hour, volunteer: @volunteer, hourable: @group_offer, hours: 2
    @feedback = create :feedback, volunteer: @volunteer, author: @volunteer.user,
      feedbackable: @group_offer

    @unrelated_group_assignment = create :group_assignment, group_offer: @group_offer
    @unrelated_hour = create :hour, volunteer: @unrelated_group_assignment.volunteer,
      hourable: @group_offer, hours: 5, comments: 'Unrelated Hour'
    @unrelated_feedback = create :feedback, volunteer: @unrelated_group_assignment.volunteer,
      author: @unrelated_group_assignment.volunteer.user, feedbackable: @group_offer
  end

  test 'volunteer_can_use_group_assignment_terminate_form' do
    login_as @volunteer.user
    visit terminate_group_assignment_path(@group_assignment)
    assert page.has_text?(/Der Einsatz (wurde|endet) am #{I18n.l(@group_assignment.period_end)}/)
    assert page.has_text? "Die Freiwillige: #{@volunteer.contact.natural_name}"
    assert page.has_text? "Das Gruppenangebot #{@group_offer.title} -
      #{@group_offer.group_offer_category.category_name}"
    assert page.has_text? @group_assignment.volunteer.hours.total_hours

    fill_in 'Was waren Ihre Hauptaktivitäten während des Einsatzes?', with: 'rand_activities_text'
    fill_in 'Welche Erfolge oder Highlights haben Sie während Ihres Einsatzes erlebt?',
      with: 'rand_success_text'
    fill_in 'Welchen Schwierigkeiten in Bezug auf Ihren Einsatz sind Sie begegnet?',
      with: 'rand_trouble_text'
    fill_in 'Wie fanden Sie die von TransFair angebotene Unterstützung inklusive Weiterbildungen und '\
      'Anlässe?', with: 'rand_transfair_text'

    page.accept_confirm do
      click_button 'Einsatz wird hiermit abgeschlossen'
    end

    assert page.has_text? 'Der Gruppeneinsatz ist hiermit abgeschlossen.'

    @group_assignment.reload
    assert_equal @volunteer.user, @group_assignment.termination_submitted_by
    assert @group_assignment.termination_submitted_at.present?
    assert_equal 'rand_activities_text', @group_assignment.term_feedback_activities
    assert_equal 'rand_success_text', @group_assignment.term_feedback_success
    assert_equal 'rand_trouble_text', @group_assignment.term_feedback_problems
    assert_equal 'rand_transfair_text', @group_assignment.term_feedback_transfair
  end

  test 'group_assignment_termination_form_adds_remaining_hours' do
    login_as @volunteer.user
    visit terminate_group_assignment_path(@group_assignment)
    fill_in 'Restliche Stunden', with: '12.35'

    page.accept_confirm do
      click_on 'Einsatz wird hiermit abgeschlossen'
    end

    visit volunteer_hours_path(@volunteer)
    assert_text '12.35'
  end

  test 'termination triggers notification email to creator' do
    ActionMailer::Base.deliveries.clear
    login_as @volunteer.user
    visit terminate_group_assignment_path(@group_assignment)
    page.accept_confirm do
      click_button 'Einsatz wird hiermit abgeschlossen'
    end

    mail = ActionMailer::Base.deliveries.last
    assert_equal @superadmin.email, mail['to'].to_s
  end
end
