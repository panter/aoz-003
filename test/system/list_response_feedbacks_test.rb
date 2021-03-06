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
      volunteer: @group_assignment_pendent.volunteer,
      author: @group_assignment_pendent.volunteer.user)
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
    assert page.has_link? 'Journal', href: volunteer_journals_path(@assignment_pendent.volunteer)
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
    assert page.has_link? 'Journal', href: volunteer_journals_path(@assignment_done.volunteer)
    assert page.has_link? @assignment_done.volunteer.contact.last_name
    assert page.has_link? @assignment_fb_done.feedbackable.to_label
    assert page.has_link? @group_assignment_done.volunteer.contact.last_name
    assert page.has_link? @group_assignment_fb_done.feedbackable.to_label
  end

  test 'feedbacks_list_with_filter_erledigt_shows_only_marked_done' do
    click_link exact_text: 'Halbjahres-Rapport Eingang'
    click_link 'Geprüft: Unquittiert'
    within 'li.dropdown.open' do
      click_link 'Quittiert'
    end
    visit current_url
    # not marked done should now be filtered
    refute page.has_link? @assignment_pendent.volunteer.contact.last_name
    refute page.has_link? @assignment_fb_pendent.feedbackable.to_label
    refute page.has_link? @group_assignment_pendent.volunteer.contact.last_name

    # marked done shoud be displayed
    assert page.has_link? 'Journal', href: volunteer_journals_path(@assignment_done.volunteer)
    assert page.has_link? @assignment_done.volunteer.contact.last_name
    assert page.has_link? @assignment_fb_done.feedbackable.to_label
    assert page.has_link? @group_assignment_done.volunteer.contact.last_name
  end

  test 'marking_feedback_done_works' do
    click_link exact_text: 'Halbjahres-Rapport Eingang'
    within 'tbody' do
      page.find("[data-url$=\"#{polymorphic_path([
        @assignment_pendent.volunteer,
        @assignment_pendent,
        @assignment_fb_pendent
      ], action: :mark_as_done)}\"]").click
    end
    wait_for_ajax
    assert page.has_link? 'Anzeigen', href: polymorphic_path([
      @assignment_pendent.volunteer,
      @assignment_pendent,
      @assignment_fb_pendent
    ])
    assert_equal @superadmin, @assignment_fb_pendent.reload.reviewer

    within 'tbody' do
      page.find("[data-url$=\"#{polymorphic_path([
        @group_assignment_fb_pendent.volunteer,
        @group_assignment_fb_pendent.feedbackable,
        @group_assignment_fb_pendent
      ], action: :mark_as_done)}\"]").click
    end
    wait_for_ajax
    assert page.has_link? 'Anzeigen', href: polymorphic_path([
      @group_assignment_fb_pendent.volunteer,
      @group_assignment_fb_pendent.feedbackable,
      @group_assignment_fb_pendent
    ])
    assert_equal @superadmin, @group_assignment_fb_pendent.reload.reviewer
  end

  test 'new_feedback_journal_entry_button_has_feedback_prefilled' do
    visit list_responses_feedbacks_path
    within 'tbody' do
      click_link href: new_volunteer_journal_path(@assignment_fb_pendent.volunteer, feedback_id: @assignment_fb_pendent.id)
    end
    assert page.has_select? 'Kategorie', with_selected: 'Rückmeldung'
    assert page.has_field? 'Titel', with: "Feedback vom #{I18n.l(@assignment_fb_pendent.created_at.to_date)}: "
  end

  test 'take_feedback_responsibility_works' do
    visit list_responses_feedbacks_path
    within 'tbody' do
      page.find("[data-url$=\"#{polymorphic_path([
        @assignment_pendent.volunteer, @assignment_pendent, @assignment_fb_pendent
      ], action: :take_responsibility)}\"]").click
    end
    wait_for_ajax
    @assignment_fb_pendent.reload
    assert page.has_text? "Übernommen durch #{@superadmin.email}"\
                          " am #{I18n.l(@assignment_fb_pendent.responsible_at.to_date)}"

    other_superadmin = create :user
    login_as other_superadmin
    visit list_responses_feedbacks_path
    within 'tbody' do
      page.find("[data-url$=\"#{polymorphic_path([
        @group_assignment_fb_pendent.volunteer,
        @group_assignment_fb_pendent.feedbackable,
        @group_assignment_fb_pendent
      ], action: :take_responsibility)}\"]").click
    end
    wait_for_ajax
    @group_assignment_fb_pendent.reload
    assert page.has_text? "Übernommen durch #{other_superadmin.email}"\
                          " am #{I18n.l(@group_assignment_fb_pendent.responsible_at.to_date)}"
  end

  test 'feedback_responsibility_filter_works' do
    @assignment_fb_pendent.update(responsible: @superadmin)
    other_superadmin = create :user
    @group_assignment_fb_pendent.update(responsible: other_superadmin)
    noone_reponsible_assignment = create(:assignment)
    noone_reponsible_feedback = create(:feedback, feedbackable: noone_reponsible_assignment,
      volunteer: noone_reponsible_assignment.volunteer,
      author: noone_reponsible_assignment.volunteer.user)
    visit list_responses_feedbacks_path

    assert page.has_text? "Übernommen durch #{other_superadmin.email}"\
                          " am #{I18n.l(@group_assignment_fb_pendent.responsible_at.to_date)}"
    assert page.has_text? "Übernommen durch #{@superadmin.email}"\
                          " am #{I18n.l(@assignment_fb_pendent.responsible_at.to_date)}"
    assert page.find("[data-url$=\"#{polymorphic_path([
      noone_reponsible_feedback.volunteer,
      noone_reponsible_feedback.feedbackable,
      noone_reponsible_feedback
    ], action: :take_responsibility)}\"]")

    within page.find_all('nav.section-navigation').last do
      click_link 'Übernommen'
      click_link 'Offen'
    end
    visit current_url
    refute page.has_text? "Übernommen durch #{other_superadmin.email}"\
                          " am #{I18n.l(@group_assignment_fb_pendent.responsible_at.to_date)}"
    refute page.has_text? "Übernommen durch #{@superadmin.email}"\
                          " am #{I18n.l(@assignment_fb_pendent.responsible_at.to_date)}"

    assert page.find("[data-url$=\"#{polymorphic_path([
      noone_reponsible_feedback.volunteer,
      noone_reponsible_feedback.feedbackable,
      noone_reponsible_feedback
    ], action: :take_responsibility)}\"]")

    click_link 'Übernommen: Offen'
    within 'li.dropdown.open' do
      click_link 'Übernommen'
    end
    visit current_url
    assert page.has_text? "Übernommen durch #{other_superadmin.email}"\
                          " am #{I18n.l(@group_assignment_fb_pendent.responsible_at.to_date)}"
    assert page.has_text? "Übernommen durch #{@superadmin.email}"\
                          " am #{I18n.l(@assignment_fb_pendent.responsible_at.to_date)}"
    refute page.has_link? 'Übernehmen', match_polymorph_path([
      noone_reponsible_feedback.volunteer,
      noone_reponsible_feedback.feedbackable,
      noone_reponsible_feedback
    ])
    click_link 'Übernommen: Übernommen'
    within 'li.dropdown.open' do
      assert page.has_link? "Übernommen von #{@superadmin.profile.contact.full_name}"
      assert page.has_link? "Übernommen von #{other_superadmin.profile.contact.full_name}"
      click_link "Übernommen von #{other_superadmin.profile.contact.full_name}"
    end
    visit current_url
    assert page.has_text? "Übernommen durch #{other_superadmin.email}"\
                          " am #{I18n.l(@group_assignment_fb_pendent.responsible_at.to_date)}"
    refute page.has_text? "Übernommen durch #{@superadmin.email}"\
                          " am #{I18n.l(@assignment_fb_pendent.responsible_at.to_date)}"
    refute page.has_link? 'Übernehmen', match_polymorph_path([
      noone_reponsible_feedback.volunteer,
      noone_reponsible_feedback.feedbackable,
      noone_reponsible_feedback
    ])
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
    assert page.has_text? 'Sie müssen eine aktive E-Mailvorlage haben, bevor Sie eine Halbjahres ' \
      'Erinnerung erstellen können.'
    assert_equal current_path, new_email_template_path
  end
end
