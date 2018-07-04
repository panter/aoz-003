require 'application_system_test_case'

class ListResponseFeedbacksTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user

    # Assignments
    @assignment_pendent = create(:assignment)
    @assignment_fb_pendent = create(:feedback, feedbackable: @assignment_pendent,
      volunteer: @assignment_pendent.volunteer, author: @assignment_pendent.volunteer.user)

    @assignment_superadmin = create(:assignment)
    @assignment_fb_superadmin = create(:feedback, feedbackable: @assignment_superadmin,
      volunteer: @assignment_superadmin.volunteer, author: @superadmin)

    @assignment_done = create(:assignment)
    @assignment_fb_done = create(:feedback, feedbackable: @assignment_done,
      volunteer: @assignment_done.volunteer, author: @assignment_done.volunteer.user,
      reviewer: @superadmin)

    # Group Offers
    @group_offer_pendent = create(:group_offer)
    @group_assignment_pendent = create(:group_assignment, group_offer: @group_offer_pendent)
    @group_assignment_fb_pendent = create(:feedback, feedbackable: @group_offer_pendent,
      volunteer: @group_assignment_pendent.volunteer, author: @group_assignment_pendent.volunteer.user)
    @group_assignment_fb_pendent.update(feedbackable: @group_offer_pendent)

    @group_offer_superadmin = create(:group_offer)
    @group_assignment_superadmin = create(:group_assignment, group_offer: @group_offer_superadmin)
    @group_assignment_fb_superadmin = create(:feedback, feedbackable: @group_offer_superadmin,
      author: @superadmin, volunteer: @group_assignment_superadmin.volunteer)
    @group_assignment_fb_pendent.update(feedbackable: @group_offer_superadmin)

    @group_offer_done = create(:group_offer)
    @group_assignment_done = create(:group_assignment, group_offer: @group_offer_done)
    @group_assignment_fb_done = create(:feedback, feedbackable: @group_offer_done,
      volunteer: @group_assignment_done.volunteer, author: @group_assignment_done.volunteer.user,
      reviewer: @superadmin)
    @group_assignment_fb_pendent.update(feedbackable: @group_offer_done)

    login_as @superadmin
    visit reminder_mailings_path
  end

  test 'feedbacks_list_contains_only_relevant_records' do
    click_link exact_text: 'Halbjahres-Rapport Eingang'
    assert page.has_link? @assignment_pendent.volunteer.contact.last_name
    assert page.has_link? @assignment_fb_pendent.feedbackable.to_label
    assert page.has_link? @group_assignment_pendent.volunteer.contact.last_name

    # marked done shoudn't be displayed
    refute page.has_link? @assignment_done.volunteer.contact.last_name
    refute page.has_link? @assignment_fb_done.feedbackable.to_label
    refute page.has_link? @group_assignment_done.volunteer.contact.last_name

    # feedback not by volunteer shouldn't be displayed
    refute page.has_link? @assignment_superadmin.volunteer.contact.last_name
    refute page.has_link? @assignment_fb_superadmin.feedbackable.to_label
    refute page.has_link? @group_assignment_superadmin.volunteer.contact.last_name
  end

  test 'feedbacks list without filter shows marked done feedback' do
    click_link exact_text: 'Halbjahres-Rapport Eingang'
    click_link 'Filter aufheben'
    visit current_url
    # marked done shoud now be displayed
    assert page.has_link? @assignment_done.volunteer.contact.last_name
    assert page.has_link? @assignment_fb_done.feedbackable.to_label
    assert page.has_link? @group_assignment_done.volunteer.contact.last_name
    assert page.has_link? @group_assignment_fb_done.feedbackable.to_label
  end

  test 'feedbacks_list_with_filter_erledigt_shows_only_marked_done' do
    click_link exact_text: 'Halbjahres-Rapport Eingang'
    click_link 'Geprüft: Ungesehen'
    within 'li.dropdown.open' do
      click_link 'Angeschaut'
    end
    visit current_url
    # not marked done should now be filtered
    refute page.has_link? @assignment_pendent.volunteer.contact.last_name
    refute page.has_link? @assignment_fb_pendent.feedbackable.to_label
    refute page.has_link? @group_assignment_pendent.volunteer.contact.last_name

    # marked done shoud be displayed
    assert page.has_link? @assignment_done.volunteer.contact.last_name
    assert page.has_link? @assignment_fb_done.feedbackable.to_label
    assert page.has_link? @group_assignment_done.volunteer.contact.last_name
  end

  test 'marking_feedback_done_works' do
    click_link exact_text: 'Halbjahres-Rapport Eingang'
    within 'tbody' do
      click_link 'Angeschaut', href: /.*\/volunteers\/#{@assignment_pendent.volunteer.id}\/
        assignments\/#{@assignment_pendent.id}\/feedbacks\/#{@assignment_fb_pendent.id}\/.*/x
    end
    assert page.has_text? 'Halbjahres-Rapport als angeschaut markiert.'
    refute page.has_link? @assignment_pendent.volunteer.contact.last_name
    refute page.has_link? @assignment_fb_pendent.feedbackable.to_label
    within 'tbody' do
      click_link 'Angeschaut', href: /feedbacks\/#{@group_assignment_fb_pendent.id}/x
    end
    assert page.has_text? 'Halbjahres-Rapport als angeschaut markiert.'
    @group_assignment_fb_pendent.reload
    assert_equal @superadmin, @group_assignment_fb_pendent.reviewer
  end

  test 'truncate_modal_shows_all_text' do
    comments = FFaker::Lorem.paragraph(20)
    achievements = FFaker::Lorem.paragraph(20)
    future = FFaker::Lorem.paragraph(20)
    @assignment_fb_pendent.update(comments: comments, achievements: achievements, future: future)
    @group_assignment_fb_pendent.update(reviewer: @superadmin)
    click_link 'Halbjahres-Rapport Eingang'
    page.find('td', text: comments.truncate(300)).click

    assert page.has_text? comments

    click_button 'Schliessen'
    page.find('td', text: future.truncate(300)).click

    assert page.has_text? future

    click_button 'Schliessen'
    page.find('td', text: achievements.truncate(300)).click

    assert page.has_text? achievements
  end

  test 'Creating new trial feedback reminder if no active mail template redirect to creating one' do
    ClientNotification.destroy_all
    click_link 'Halbjahres Erinnerung erstellen'
    assert page.has_text? 'Sie müssen eine aktive E-Mailvorlage haben, bevor Sie eine Halbjahres Erinnerung erstellen können.'
    assert_equal current_path, new_email_template_path
  end
end
