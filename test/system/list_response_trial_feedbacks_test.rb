require 'application_system_test_case'

class ListResponseTrialFeedbacksTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @assignment_pendent = create(:assignment)
    @assignment_fb_pendent = create :trial_feedback, volunteer: @assignment_pendent.volunteer,
      trial_feedbackable: @assignment_pendent, author: @assignment_pendent.volunteer.user
    @assignment_superadmin = create(:assignment)
    @assignment_fb_superadmin = create :trial_feedback, volunteer: @assignment_superadmin.volunteer,
      trial_feedbackable: @assignment_superadmin, author: @superadmin
    @assignment_done = create(:assignment)
    @assignment_fb_done = create :trial_feedback, trial_feedbackable: @assignment_done,
      volunteer: @assignment_done.volunteer, author: @assignment_done.volunteer.user,
      reviewer: @superadmin

    @group_offer_pendent = create :group_offer
    @group_assignment_pendent = create :group_assignment, group_offer: @group_offer_pendent
    @group_assignment_fb_pendent = create :trial_feedback, volunteer: @group_assignment_pendent.volunteer,
      trial_feedbackable: @group_offer_pendent,
      author: @group_assignment_pendent.volunteer.user
    @group_offer_superadmin = create :group_offer
    @group_assignment_superadmin = create :group_assignment, group_offer: @group_offer_superadmin
    @group_assignment_fb_superadmin = create :trial_feedback, author: @superadmin,
      volunteer: @group_assignment_superadmin.volunteer, trial_feedbackable: @group_offer_superadmin
    @group_offer_done = create :group_offer
    @group_assignment_done = create :group_assignment, group_offer: @group_offer_done
    @group_assignment_fb_done = create :trial_feedback, volunteer: @group_assignment_done.volunteer,
      trial_feedbackable: @group_offer_done, author: @group_assignment_done.volunteer.user,
      reviewer: @superadmin
    login_as @superadmin
    visit reminder_mailings_path
  end

  test 'feedbacks_list_contains_only_relevant_records' do
    click_link 'Probezeit Feedback Eingang'
    assert page.has_link? @assignment_pendent.volunteer.contact.last_name
    assert page.has_link? @assignment_fb_pendent.trial_feedbackable.to_label
    assert page.has_link? @group_assignment_pendent.volunteer.contact.last_name
    assert page.has_link? @group_assignment_fb_pendent.trial_feedbackable.to_label

    # marked done shoudn't be displayed
    refute page.has_link? @assignment_done.volunteer.contact.last_name
    refute page.has_link? @assignment_fb_done.trial_feedbackable.to_label
    refute page.has_link? @group_assignment_done.volunteer.contact.last_name
    refute page.has_link? @group_assignment_fb_done.trial_feedbackable.to_label

    # feedback not by volunteer shouldn't be displayed
    refute page.has_link? @assignment_superadmin.volunteer.contact.last_name
    refute page.has_link? @assignment_fb_superadmin.trial_feedbackable.to_label
    refute page.has_link? @group_assignment_superadmin.volunteer.contact.last_name
    refute page.has_link? @group_assignment_fb_superadmin.trial_feedbackable.to_label
  end

  test 'feedbacks list without filter shows marked done feedback' do
    click_link 'Probezeit Feedback Eingang'
    click_link 'Filter aufheben'
    visit current_url
    # marked done shoud now be displayed
    assert page.has_link? @assignment_done.volunteer.contact.last_name
    assert page.has_link? @assignment_fb_done.trial_feedbackable.to_label
    assert page.has_link? @group_assignment_done.volunteer.contact.last_name
    assert page.has_link? @group_assignment_fb_done.trial_feedbackable.to_label
  end

  test 'feedbacks_list_with_filter_erledigt_shows_only_marked_done' do
    click_link 'Probezeit Feedback Eingang'
    click_link 'Geprüft: Ungesehen'
    within 'li.dropdown.open' do
      click_link 'Angeschaut'
    end
    visit current_url
    # not marked done should now be filtered
    refute page.has_link? @assignment_pendent.volunteer.contact.last_name
    refute page.has_link? @assignment_fb_pendent.trial_feedbackable.to_label
    refute page.has_link? @group_assignment_pendent.volunteer.contact.last_name
    refute page.has_link? @group_assignment_fb_pendent.trial_feedbackable.to_label

    # marked done shoud be displayed
    assert page.has_link? @assignment_done.volunteer.contact.last_name
    assert page.has_link? @assignment_fb_done.trial_feedbackable.to_label
    assert page.has_link? @group_assignment_done.volunteer.contact.last_name
    assert page.has_link? @group_assignment_fb_done.trial_feedbackable.to_label
  end

  test 'marking_feedback_done_works' do
    click_link 'Probezeit Feedback Eingang'
    within 'tbody' do
      click_link 'Angeschaut', href: /.*\/volunteers\/#{@assignment_pendent.volunteer.id}\/
        assignments\/#{@assignment_pendent.id}\/trial_feedbacks
        \/#{@assignment_fb_pendent.id}\/.*/x
    end
    assert page.has_text? 'Feedback als angeschaut markiert.'
    refute page.has_link? @assignment_pendent.volunteer.contact.last_name
    refute page.has_link? @assignment_fb_pendent.trial_feedbackable.to_label
    within 'tbody' do
      click_link 'Angeschaut', href: /.*\/volunteers\/#{@group_assignment_pendent.volunteer.id}\/
        group_offers\/#{@group_assignment_pendent.group_offer.id}\/trial_feedbacks
        \/#{@group_assignment_fb_pendent.id}\/.*/x
    end
    assert page.has_text? 'Feedback als angeschaut markiert.'
  end

  test 'truncate_modal_shows_all_text' do
    body = Faker::Lorem.paragraph(50)
    @assignment_fb_pendent.update(body: body)
    @group_assignment_fb_pendent.update(reviewer: @superadmin)
    click_link 'Probezeit Feedback Eingang'
    page.find('td', text: body.truncate(500)).click
    wait_for_ajax
    assert page.has_text? body
    click_button 'Schliessen'
  end

  test 'Creating new trial feedback reminder if no active mail template redirect to creating one' do
    ClientNotification.destroy_all
    click_link 'Probezeit Erinnerung erstellen'
    assert page.has_text? 'Sie müssen eine aktive E-Mailvorlage haben, bevor Sie eine Probezeit Erinnerung erstellen können.'
    assert_equal current_path, new_email_template_path
  end
end
