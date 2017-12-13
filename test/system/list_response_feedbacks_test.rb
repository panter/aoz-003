require 'application_system_test_case'

class ListResponseFeedbacksTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @assignment_pendent = create(:assignment)
    @assignment_fb_pendent = create :feedback, volunteer: @assignment_pendent.volunteer,
      feedbackable: @assignment_pendent, author: @assignment_pendent.volunteer.user
    @assignment_superadmin = create(:assignment)
    @assignment_fb_superadmin = create :feedback, volunteer: @assignment_superadmin.volunteer,
      feedbackable: @assignment_superadmin, author: @superadmin
    @assignment_done = create(:assignment)
    @assignment_fb_done = create :feedback, feedbackable: @assignment_done,
      volunteer: @assignment_done.volunteer, author: @assignment_done.volunteer.user,
      reviewer: @superadmin

    @group_assignment_pendent = create :group_assignment
    @group_assignment_fb_pendent = create :feedback, volunteer: @group_assignment_pendent.volunteer,
      feedbackable: @group_assignment_pendent, author: @group_assignment_pendent.volunteer.user
    @group_assignment_superadmin = create :group_assignment
    @group_assignment_fb_superadmin = create :feedback, author: @superadmin,
      volunteer: @group_assignment_superadmin.volunteer,
      feedbackable: @group_assignment_superadmin
    @group_assignment_done = create :group_assignment
    @group_assignment_fb_done = create :feedback, volunteer: @group_assignment_done.volunteer,
      feedbackable: @group_assignment_done, author: @group_assignment_done.volunteer.user,
      reviewer: @superadmin
    login_as @superadmin
    visit reminder_mailings_path
  end

  test 'feedbacks_list_contains_only_relevant_records' do
    click_link 'Feedback Eingang', href: /.*\/feedbacks\?.*$/
    assert page.has_link? @assignment_pendent.volunteer.contact.last_name
    assert page.has_link? @assignment_fb_pendent.feedbackable.to_label
    assert page.has_link? @group_assignment_pendent.volunteer.contact.last_name
    assert page.has_link? @group_assignment_fb_pendent.feedbackable.to_label

    # marked done shoudn't be displayed
    refute page.has_link? @assignment_done.volunteer.contact.last_name
    refute page.has_link? @assignment_fb_done.feedbackable.to_label
    refute page.has_link? @group_assignment_done.volunteer.contact.last_name
    refute page.has_link? @group_assignment_fb_done.feedbackable.to_label

    # feedback not by volunteer shouldn't be displayed
    refute page.has_link? @assignment_superadmin.volunteer.contact.last_name
    refute page.has_link? @assignment_fb_superadmin.feedbackable.to_label
    refute page.has_link? @group_assignment_superadmin.volunteer.contact.last_name
    refute page.has_link? @group_assignment_fb_superadmin.feedbackable.to_label
  end

  test 'feedbacks list without filter shows marked done feedback' do
    click_link 'Feedback Eingang', href: /.*\/feedbacks\?.*$/
    click_link 'Filter aufheben'
    visit current_url
    # marked done shoud now be displayed
    assert page.has_link? @assignment_done.volunteer.contact.last_name
    assert page.has_link? @assignment_fb_done.feedbackable.to_label
    assert page.has_link? @group_assignment_done.volunteer.contact.last_name
    assert page.has_link? @group_assignment_fb_done.feedbackable.to_label
  end

  test 'feedbacks list with filter erledigt shows only marked done' do
    click_link 'Feedback Eingang', href: /.*\/feedbacks\?.*$/
    click_link 'Geprüft: Ungesehen'
    within 'li.dropdown.open' do
      click_link 'Angeschaut'
    end
    visit current_url
    # not marked done should now be filtered
    refute page.has_link? @assignment_pendent.volunteer.contact.last_name
    refute page.has_link? @assignment_fb_pendent.feedbackable.to_label
    refute page.has_link? @group_assignment_pendent.volunteer.contact.last_name
    refute page.has_link? @group_assignment_fb_pendent.feedbackable.to_label

    # marked done shoud be displayed
    assert page.has_link? @assignment_done.volunteer.contact.last_name
    assert page.has_link? @assignment_fb_done.feedbackable.to_label
    assert page.has_link? @group_assignment_done.volunteer.contact.last_name
    assert page.has_link? @group_assignment_fb_done.feedbackable.to_label
  end

  test 'marking_feedback_done_works' do
    click_link 'Feedback Eingang', href: /.*\/feedbacks\?.*$/
    within 'tbody' do
      click_link 'Angeschaut', href: /.*\/volunteers\/#{@assignment_pendent.volunteer.id}\/
        assignments\/#{@assignment_pendent.id}\/feedbacks\/#{@assignment_fb_pendent.id}\/.*/x
    end
    assert page.has_text? 'Feedback als angeschaut markiert.'
    refute page.has_link? @assignment_pendent.volunteer.contact.last_name
    refute page.has_link? @assignment_fb_pendent.feedbackable.to_label
    within 'tbody' do
      click_link 'Angeschaut', href: /.*\/volunteers\/#{@group_assignment_pendent.volunteer.id}\/
        group_offers\/#{@group_assignment_pendent.id}\/feedbacks
        \/#{@group_assignment_fb_pendent.id}\/.*/x
    end
    assert page.has_text? 'Feedback als angeschaut markiert.'
  end

  test 'truncate_modal_shows_all_text' do
    comments = Faker::Lorem.paragraph(20)
    achievements = Faker::Lorem.paragraph(20)
    future = Faker::Lorem.paragraph(20)
    @assignment_fb_pendent.update(comments: comments, achievements: achievements, future: future)
    @group_assignment_fb_pendent.update(reviewer: @superadmin)
    click_link 'Feedback Eingang', href: /.*\/feedbacks\?.*$/
    page.find('td', text: comments.truncate(60)).click
    wait_for_ajax
    assert page.has_text? comments
    click_button 'Schliessen'
    page.find('td', text: future.truncate(60)).click
    wait_for_ajax
    assert page.has_text? future
    click_button 'Schliessen'
    page.find('td', text: achievements.truncate(60)).click
    wait_for_ajax
    assert page.has_text? achievements
    click_button 'Schliessen'
  end
end
