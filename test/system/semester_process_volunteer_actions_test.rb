require 'application_system_test_case'

class SemesterProcessVolunteerActionsTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user
    @volunteer = create :volunteer_with_user
    @volunteer.contact.update(first_name: 'Walter', last_name: 'White')
    @assignment = create :assignment, volunteer: @volunteer
    @group_assignment = create :group_assignment, volunteer: @volunteer

    @semester_process = create :semester_process
    @spv1 = create(:semester_process_volunteer, :with_mission, volunteer: @volunteer,
      semester_process: @semester_process)

    login_as @superadmin
  end

  test 'take responsibility for semester process volunteer works' do
    visit semester_process_volunteers_path
    within 'tbody' do
      page.find("[data-url$=\"#{take_responsibility_semester_process_volunteer_path(@spv1)}\"]").click
    end
    wait_for_ajax
    @spv1.reload
    assert page.has_text? "Übernommen durch #{@superadmin.email}"\
    " am #{I18n.l(@spv1.responsibility_taken_at.to_date)}"
  end

  test 'take responsibility for semester process volunteer filter works' do
    login_as @superadmin
    visit semester_process_volunteers_path

    ## SETUP ##
    # Offen/open -> @spv1
    # Übernommen/responsibility taken over from superadmin1
    @volunteer2 = create :volunteer_with_user
    @volunteer2.contact.update(first_name: 'volunteer2', last_name: 'volunteer2')
    @spv2 = create(:semester_process_volunteer, :with_mission, volunteer: @volunteer2,
      semester_process: @semester_process)
    @superadmin2 = create :user
    @spv2.update(responsible: @superadmin2)

    # Übernommen/responsibility taken over from superadmin2
    @volunteer3 = create :volunteer_with_user
    @volunteer3.contact.update(first_name: 'volunteer3', last_name: 'volunteer3')
    @spv3 = create(:semester_process_volunteer, :with_mission, volunteer: @volunteer3,
      semester_process: @semester_process)
    @superadmin3 = create :user
    @spv3.update(responsible: @superadmin3)
    ## SETUP END ##

    # filter for Alle/all
    within page.find_all('nav.section-navigation').last do
      click_link 'Übernommen'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert page.find("[data-url$=\"#{take_responsibility_semester_process_volunteer_path(@spv1)}\"]")
    end
    assert page.has_text? "Übernommen durch #{@superadmin2.email}"\
                          " am #{I18n.l(@spv2.responsibility_taken_at.to_date)}"
    assert page.has_text? "Übernommen durch #{@superadmin3.email}"\
                          " am #{I18n.l(@spv3.responsibility_taken_at.to_date)}"

    # filter for Offen/open
    within page.find_all('nav.section-navigation').last do
      click_link 'Übernommen'
      click_link 'Offen'
    end
    visit current_url
    within 'tbody' do
      assert page.find("[data-url$=\"#{take_responsibility_semester_process_volunteer_path(@spv1)}\"]")
    end
    refute page.has_text? "Übernommen durch #{@superadmin2.email}"\
                          " am #{I18n.l(@spv2.responsibility_taken_at.to_date)}"
    refute page.has_text? "Übernommen durch #{@superadmin3.email}"\
                          " am #{I18n.l(@spv3.responsibility_taken_at.to_date)}"

    # filter for Übernommen/responsibility taken over in general
    click_link 'Übernommen: Offen', match: :first
    within 'li.dropdown.open' do
      click_link 'Übernommen'
    end
    visit current_url
    refute page.has_link? 'Übernehmen', href: take_responsibility_semester_process_volunteer_path(@spv1)
    assert page.has_text? "Übernommen durch #{@superadmin2.email}"\
                          " am #{I18n.l(@spv2.responsibility_taken_at.to_date)}"
    assert page.has_text? "Übernommen durch #{@superadmin3.email}"\
                          " am #{I18n.l(@spv3.responsibility_taken_at.to_date)}"

    # filter for Übernommen von superadmin1/responsibility taken over by superadmin1
    click_link 'Übernommen: Übernommen', match: :first
    within 'li.dropdown.open' do
      assert page.has_link? "Übernommen von #{@superadmin2.profile.contact.full_name}"
      assert page.has_link? "Übernommen von #{@superadmin3.profile.contact.full_name}"
      click_link "Übernommen von #{@superadmin2.profile.contact.full_name}"
    end
    visit current_url
    refute page.has_link? 'Übernehmen', href: take_responsibility_semester_process_volunteer_path(@spv1)
    assert page.has_text? "Übernommen durch #{@superadmin2.email}"\
                          " am #{I18n.l(@spv2.responsibility_taken_at.to_date)}"
    refute page.has_text? "Übernommen durch #{@superadmin3.email}"\
                          " am #{I18n.l(@spv3.responsibility_taken_at.to_date)}"
  end
end
