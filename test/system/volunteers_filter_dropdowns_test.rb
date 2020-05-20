require 'application_system_test_case'

class VolunteersFilterDropdownsTest < ApplicationSystemTestCase
  def setup
    @user = create :user, role: 'superadmin'
    @c1 = create :group_offer_category
    @c2 = create :group_offer_category
    @c3 = create :group_offer_category
    @volunteer1 = create :volunteer, group_offer_categories: [@c1, @c2]
    @volunteer2 = create :volunteer, group_offer_categories: [@c2, @c3]
    @volunteer3 = create :volunteer
    Volunteer.acceptance_collection.map do |acceptance|
      [
        create(:volunteer, acceptance: acceptance,
                           man: true,
                           morning: true,
                           salutation: 'mrs'),
        create(:volunteer, acceptance: acceptance,
                           man: true,
                           woman: true,
                           workday: true,
                           salutation: 'mr')
      ]
    end
    login_as @user
    visit volunteers_path
  end

  test 'filter_by_acceptance_works_and_disabling_works_as_well' do
    within '.section-navigation' do
      click_link 'Prozess'
      click_link 'Angemeldet'
    end
    visit current_url
    within 'tbody' do
      assert_text 'Angemeldet'
      refute_text 'Akzeptiert', wait: 0
    end
    within '.section-navigation' do
      click_link 'Prozess: Angemeldet'
      assert page.has_link? exact_text: 'Angemeldet', class: 'bg-success'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert_text 'Akzeptiert'
      assert_text 'Angemeldet'
    end
  end

  test 'Filter acceptance and salutation at the same time' do
    within '.section-navigation' do
      click_link 'Anrede'
      click_link 'Herr'
    end
    visit current_url
    within '.section-navigation' do
      click_link 'Prozess'
      click_link 'Akzeptiert'
    end
    visit current_url
    within 'tbody' do
      assert_text 'Herr'
      refute_text 'Frau', wait: 0
      assert_text 'Akzeptiert'
      refute_text 'Abgelehnt', wait: 0
    end
    within '.section-navigation' do
      click_link 'Anrede: Herr'
      assert page.has_link? 'Herr', class: 'bg-success'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert_text 'Frau'
      assert_text 'Herr'
      assert_text 'Akzeptiert'
      refute_text 'Abgelehnt', wait: 0
    end
    click_link 'Filter aufheben'
    visit current_url
    within 'tbody' do
      assert_text 'Frau'
      assert_text 'Herr'
      assert_text 'Akzeptiert'
      assert_text 'Abgelehnt'
    end
  end

  test 'boolean filters for single accompainment' do
    false_volunteer = create :volunteer, man: false, woman: false, morning: false, workday: false
    within '.section-navigation' do
      click_link 'Interessiert an Einzelbegleitung'
      click_link 'Mann'
    end
    visit current_url
    within 'tbody' do
      assert_text Volunteer.where(man: true).first.to_s
      refute_text false_volunteer.to_s, wait: 0
    end
    within '.section-navigation' do
      click_link 'Interessiert an Einzelbegleitung'
      assert page.has_link? 'Mann', class: 'bg-success'
      click_link 'Frau'
    end
    visit current_url
    within 'tbody' do
      assert_text Volunteer.where(woman: true).first.to_s
      refute_text false_volunteer.to_s, wait: 0
    end
    within '.section-navigation' do
      click_link 'Interessiert an Einzelbegleitung'
      assert page.has_link? 'Mann', class: 'bg-success'
      assert page.has_link? 'Frau', class: 'bg-success'
      click_link 'Frau'
    end
    visit current_url
    within 'tbody' do
      assert_text Volunteer.where(man: true, woman: false).first.to_s
    end
    click_link 'Filter aufheben'
    visit current_url
    within 'tbody' do
      assert_text false_volunteer.to_s
    end
  end

  test 'Filter for group offer categories' do
    within '.section-navigation' do
      click_link 'Interessiert an Gruppenangebot Kategorie'
      click_link @c1
    end
    visit current_url
    within 'tbody' do
      assert_text @volunteer1
      refute_text @volunteer2, wait: 0
      refute_text @volunteer3, wait: 0
    end
    within '.section-navigation' do
      click_link 'Interessiert an Gruppenangebot Kategorie'
      click_link @c3
    end
    visit current_url
    within 'tbody' do
      assert_text @volunteer2
      refute_text @volunteer1, wait: 0
      refute_text @volunteer3, wait: 0
    end
    within '.section-navigation' do
      click_link 'Interessiert an Gruppenangebot Kategorie'
      click_link @c2
    end
    visit current_url
    within 'tbody' do
      assert_text @volunteer1
      assert_text @volunteer2
      refute_text @volunteer3, wait: 0
    end
    click_link 'Filter aufheben'
    visit current_url
    within 'tbody' do
      assert_text @volunteer1
      assert_text @volunteer2
      assert_text @volunteer1
    end
  end

  test 'thead_acceptance_filter_dropdown_by_default_shows_all' do
    visit volunteers_path
    within 'tbody' do
      assert_text 'Akzeptiert'
      assert_text 'Angemeldet'
      assert_text 'Eingeladen'
      assert_text 'Abgelehnt'
      assert_text 'Beendet'
    end
  end

  test 'choosing_acceptance_resigned_works' do
    visit volunteers_path
    within '.section-navigation' do
      click_link 'Prozess'
      click_link 'Beendet'
    end
    visit current_url
    within 'tbody' do
      assert_text 'Beendet'
      refute_text 'Akzeptiert', wait: 0
      refute_text 'Angemeldet', wait: 0
      refute_text 'Eingeladen', wait: 0
      refute_text 'Abgelehnt', wait: 0
    end
  end

  test 'filter by process' do
    # clean existing volunteers first created by setup
    Volunteer.destroy_all

    # load test data
    @volunteer_not_logged_in = Volunteer.create!(contact: create(:contact),
                                                 acceptance: :accepted,
                                                 salutation: :mrs,
                                                 birth_year: '1995-10-11')
    Volunteer.acceptance_collection.each do |acceptance|
      volunteer = create :volunteer, acceptance: acceptance, salutation: 'mrs'
      instance_variable_set("@volunteer_#{acceptance}", volunteer)
    end

    # test process filter dropdown
    visit volunteers_path

    click_link 'Prozess'
    click_link 'Nie eingeloggt', match: :first
    assert_text @volunteer_not_logged_in

    Volunteer.invited_but_never_logged_in.each do |volunteer|
      within "tr##{dom_id volunteer}" do
        assert_text 'Nie eingeloggt'
      end
    end

    Volunteer.acceptance_collection.each do |acceptance|
      volunteer = instance_variable_get("@volunteer_#{acceptance}")
      other_acceptances = Volunteer.acceptance_collection - [acceptance]

      visit volunteers_path
      click_link 'Prozess'
      click_link Volunteer.human_attribute_name(acceptance), match: :first

      assert_text volunteer

      other_acceptances.each do |other_acceptance|
        other_volunteer = instance_variable_get("@volunteer_#{other_acceptance}")
        refute_text other_volunteer, wait: 0
      end
    end
  end
end
