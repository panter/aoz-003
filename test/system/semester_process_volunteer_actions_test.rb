require 'application_system_test_case'

class SemesterProcessVolunteerActionsTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user
    @volunteer = create :volunteer_with_user
    @volunteer.contact.update(first_name: 'Walter', last_name: 'White')
    @assignment = create :assignment, volunteer: @volunteer
    @group_assignment = create :group_assignment, volunteer: @volunteer

    @semester_process = create :semester_process
    @spv1 = create(:semester_process_volunteer, :with_mission, :with_mail, volunteer: @volunteer,
      semester_process: @semester_process)

    login_as @superadmin
    visit semester_process_volunteers_path(semester: Semester.to_s(@semester_process.semester))
  end

  def action_on_semester_process_volunteer_index(path, text)
    within 'tbody' do
      page.find("[data-url$=\"#{path}\"]").click
    end
    wait_for_ajax
    @spv1.reload
    assert_text "#{text} #{@superadmin.email}", normalize_ws: true
  end

  def filters_setup
    ## SETUP ##
    # Offen/open -> @spv1

    # Übernommen/Quittiert from superadmin2
    # Bestätigt from volunteer 2
    @volunteer2 = create :volunteer_with_user
    @volunteer2.contact.update(first_name: 'volunteer2', last_name: 'volunteer2')
    @spv2 = create(:semester_process_volunteer, :with_mission, :with_mail, volunteer: @volunteer2,
      semester_process: @semester_process)
    @superadmin2 = create :user
    @spv2.update(responsible: @superadmin2, reviewed_by: @superadmin2, reviewed_at: Time.zone.now,
      commited_by: @volunteer2.user)

    # Übernommen/Quittiert from superadmin3
    # Unbestätigt
    @volunteer3 = create :volunteer_with_user
    @volunteer3.contact.update(first_name: 'volunteer3', last_name: 'volunteer3')
    @spv3 = create(:semester_process_volunteer, :with_mission, :with_mail, volunteer: @volunteer3,
      semester_process: @semester_process)
    @superadmin3 = create :user
    @spv3.update(responsible: @superadmin3, reviewed_by: @superadmin3, reviewed_at: Time.zone.now)
    ## SETUP END ##
  end

  test 'take responsibility for semester process volunteer works' do
    path = take_responsibility_semester_process_volunteer_path(@spv1)
    text = 'Übernommen durch'
    action_on_semester_process_volunteer_index(path, text)
  end

  test 'quittieren for semester process volunteer works' do
    path = mark_as_done_semester_process_volunteer_path(@spv1)
    text = 'Quittiert von'
    action_on_semester_process_volunteer_index(path, text)
  end

  test 'take responsibility for semester process volunteer filter works' do
    filters_setup
    # filter for Alle/all
    within page.find_all('nav.section-navigation').last do
      click_link 'Übernommen'
      click_link 'Alle'
    end
    within 'tbody' do
      assert page.find("[data-url$=\"#{take_responsibility_semester_process_volunteer_path(@spv1)}\"]")
    end
    assert_text "Übernommen durch #{@superadmin2.email}"\
                " am #{I18n.l(@spv2.responsibility_taken_at.to_date)}",
                normalize_ws: true
    assert_text "Übernommen durch #{@superadmin3.email}"\
                " am #{I18n.l(@spv3.responsibility_taken_at.to_date)}",
                normalize_ws: true

    # filter for Offen/open
    within page.find_all('nav.section-navigation').last do
      click_link 'Übernommen'
      click_link 'Offen'
    end
    visit current_url
    within 'tbody' do
      assert page.find("[data-url$=\"#{take_responsibility_semester_process_volunteer_path(@spv1)}\"]")
    end
    refute_text "Übernommen durch #{@superadmin2.email}"\
                " am #{I18n.l(@spv2.responsibility_taken_at.to_date)}",
                wait: 0, normalize_ws: true
    refute_text "Übernommen durch #{@superadmin3.email}"\
                " am #{I18n.l(@spv3.responsibility_taken_at.to_date)}",
                wait: 0, normalize_ws: true

    # filter for Übernommen/responsibility taken over in general
    click_link 'Übernommen: Offen', match: :first
    within 'li.dropdown.open' do
      click_link 'Übernommen'
    end
    visit current_url
    assert_text "Übernommen durch #{@superadmin2.email}"\
                " am #{I18n.l(@spv2.responsibility_taken_at.to_date)}",
                normalize_ws: true
    assert_text "Übernommen durch #{@superadmin3.email}"\
                " am #{I18n.l(@spv3.responsibility_taken_at.to_date)}",
                normalize_ws: true
    refute_link 'Übernehmen',
                href: take_responsibility_semester_process_volunteer_path(@spv1),
                wait: 0

    # filter for Übernommen von superadmin1/responsibility taken over by superadmin1
    click_link 'Übernommen: Übernommen', match: :first
    within 'li.dropdown.open' do
      assert_link "Übernommen von #{@superadmin2.profile.contact.full_name}",
                  normalize_ws: true
      assert_link "Übernommen von #{@superadmin3.profile.contact.full_name}",
                  normalize_ws: true
      click_link "Übernommen von #{@superadmin2.profile.contact.full_name}",
                 normalize_ws: true
    end
    visit current_url
    assert_text "Übernommen durch #{@superadmin2.email}"\
                " am #{I18n.l(@spv2.responsibility_taken_at.to_date)}",
                normalize_ws: true
    refute_link 'Übernehmen',
                href: take_responsibility_semester_process_volunteer_path(@spv1),
                wait: 0
    refute_text "Übernommen durch #{@superadmin3.email}"\
                " am #{I18n.l(@spv3.responsibility_taken_at.to_date)}",
                wait: 0, normalize_ws: true
  end

  test 'quittieren for semester process volunteer filter works' do
    filters_setup
    # filter for Alle/all (Quittieren)
    within page.find_all('nav.section-navigation').last do
      click_link 'Quittiert'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert_css "[data-url$=\"#{mark_as_done_semester_process_volunteer_path(@spv1)}\"]"
    end
    assert_text "Quittiert von #{@superadmin2.email}"\
                " am #{I18n.l(@spv2.reviewed_at.to_date)}",
                normalize_ws: true
    assert_text "Quittiert von #{@superadmin3.email}"\
                " am #{I18n.l(@spv3.reviewed_at.to_date)}",
                normalize_ws: true

    # filter for Unquittiert
    within page.find_all('nav.section-navigation').last do
      click_link 'Quittiert'
      click_link 'Unquittiert'
    end
    visit current_url
    within 'tbody' do
      assert_css "[data-url$=\"#{mark_as_done_semester_process_volunteer_path(@spv1)}\"]"
    end
    refute_text "Quittiert von #{@superadmin2.email}"\
                " am #{I18n.l(@spv2.reviewed_at.to_date)}",
                wait: 0,
                normalize_ws: true
    refute_text "Quittiert von #{@superadmin3.email}"\
                " am #{I18n.l(@spv3.reviewed_at.to_date)}",
                wait: 0,
                normalize_ws: true

    # filter for Quittiert/mark_as_done in general
    click_link 'Quittiert: Unquittiert', match: :first
    within 'li.dropdown.open' do
      click_link 'Quittiert'
    end
    visit current_url
    assert_text "Quittiert von #{@superadmin2.email}"\
                " am #{I18n.l(@spv2.reviewed_at.to_date)}",
                normalize_ws: true
    assert_text "Quittiert von #{@superadmin3.email}"\
                " am #{I18n.l(@spv3.reviewed_at.to_date)}",
                normalize_ws: true
    refute_link 'Quittieren',
                href: mark_as_done_semester_process_volunteer_path(@spv1),
                wait: 0

    # filter for quittiert/mark_as_done by superadmin1
    click_link 'Quittiert: Quittiert', match: :first
    within 'li.dropdown.open' do
      assert_link "Quittiert von #{@superadmin2.profile.contact.full_name}",
                  normalize_ws: true
      assert_link "Quittiert von #{@superadmin3.profile.contact.full_name}",
                  normalize_ws: true
      click_link "Quittiert von #{@superadmin2.profile.contact.full_name}"
    end
    visit current_url
    assert_text "Quittiert von #{@superadmin2.email}"\
                " am #{I18n.l(@spv2.reviewed_at.to_date)}",
                normalize_ws: true
    refute_link 'Quittieren',
                href: mark_as_done_semester_process_volunteer_path(@spv1),
                wait: 0
    refute_text "Quittiert von #{@superadmin3.email}"\
                " am #{I18n.l(@spv3.reviewed_at.to_date)}",
                normalize_ws: true,
                wait: 0
  end

  test 'bestätigt for semester process volunteer index works' do
    filters_setup
    # filter for Alle/all (Bestätigt)
    within page.find_all('nav.section-navigation').last do
      click_link 'Bestätigt'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert_text @volunteer.contact.full_name
      assert_text @volunteer2.contact.full_name
      assert_text @volunteer3.contact.full_name
    end

    # filter for Unbestätigt
    within page.find_all('nav.section-navigation').last do
      click_link 'Bestätigt'
      click_link 'Unbestätigt'
    end
    visit current_url
    within 'tbody' do
      assert_text @volunteer.contact.full_name
      refute_text @volunteer2.contact.full_name, wait: 0
      assert_text @volunteer3.contact.full_name
    end

    # filter for Bestätigt
    click_link 'Bestätigt: Unbestätigt', match: :first
    within 'li.dropdown.open' do
      click_link 'Bestätigt'
    end
    visit current_url
    within 'tbody' do
      assert_text @volunteer2.contact.full_name
      refute_text @volunteer.contact.full_name, wait: 0
      refute_text @volunteer3.contact.full_name, wait: 0
    end
  end
  test 'notes are editable' do
    first('.update_notes .field_label').click
    first('.update_notes .field_input').fill_in(with: 'notesnotesnotes')
    first('div.wrapper').click
    wait_for_ajax
    @spv1.reload
    assert_text 'notesnotesnotes', normalize_ws: true
    assert_equal @spv1.notes, 'notesnotesnotes'
  end
end
