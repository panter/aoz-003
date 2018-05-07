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
        create(:volunteer, acceptance: acceptance, man: true, morning: true, salutation: 'mrs'),
        create(:volunteer, acceptance: acceptance, man: true, woman: true, workday: true, salutation: 'mr')
      ]
    end
    login_as @user
    visit volunteers_path
  end

  test 'filter by acceptance works and disabling works as well' do
    within '.section-navigation' do
      click_link 'Prozess'
      click_link 'Angemeldet'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? 'Angemeldet'
      refute page.has_text? 'Akzeptiert'
    end
    within '.section-navigation' do
      click_link 'Prozess: Angemeldet'
      assert page.has_link? text: 'Angemeldet', class: 'bg-undecided'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? 'Akzeptiert'
      assert page.has_text? 'Angemeldet'
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
      assert page.has_text? 'Herr'
      refute page.has_text? 'Frau'
      assert page.has_text? 'Akzeptiert'
      refute page.has_text? 'Abgelehnt'
    end
    within '.section-navigation' do
      click_link 'Anrede: Herr'
      assert page.has_link? 'Herr', class: 'bg-success'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? 'Frau'
      assert page.has_text? 'Herr'
      assert page.has_text? 'Akzeptiert'
      refute page.has_text? 'Abgelehnt'
    end
    click_link 'Filter aufheben'
    visit current_url
    within 'tbody' do
      assert page.has_text? 'Frau'
      assert page.has_text? 'Herr'
      assert page.has_text? 'Akzeptiert'
      assert page.has_text? 'Abgelehnt'
    end
  end

  test 'boolean filters for single accompainment' do
    false_volunteer = create :volunteer, man: false, woman: false, morning: false, workday: false
    within '.section-navigation' do
      click_link 'Einzelbegleitungen'
      click_link 'Mann'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? Volunteer.where(man: true).first.to_s
      refute page.has_text? false_volunteer.to_s
    end
    within '.section-navigation' do
      click_link 'Einzelbegleitungen'
      assert page.has_link? 'Mann', class: 'bg-success'
      click_link 'Frau'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? Volunteer.where(woman: true).first.to_s
      refute page.has_text? false_volunteer.to_s
    end
    within '.section-navigation' do
      click_link 'Einzelbegleitungen'
      assert page.has_link? 'Mann', class: 'bg-success'
      assert page.has_link? 'Frau', class: 'bg-success'
      click_link 'Frau'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? Volunteer.where(man: true, woman: false).first.to_s
    end
    click_link 'Filter aufheben'
    visit current_url
    within 'tbody' do
      assert page.has_text? false_volunteer.to_s
    end
  end

  test 'Filter for group offer categories' do
    within '.section-navigation' do
      click_link 'Interessiert an Gruppenangebot Kategorie'
      click_link @c1
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @volunteer1
      refute page.has_text? @volunteer2
      refute page.has_text? @volunteer3
    end
    within '.section-navigation' do
      click_link 'Interessiert an Gruppenangebot Kategorie'
      click_link @c3
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @volunteer2
      refute page.has_text? @volunteer1
      refute page.has_text? @volunteer3
    end
    within '.section-navigation' do
      click_link 'Interessiert an Gruppenangebot Kategorie'
      click_link @c2
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @volunteer1
      assert page.has_text? @volunteer2
      refute page.has_text? @volunteer3
    end
    click_link 'Filter aufheben'
    visit current_url
    within 'tbody' do
      assert page.has_text? @volunteer1
      assert page.has_text? @volunteer2
      assert page.has_text? @volunteer1
    end
  end

  test 'thead_acceptance_filter_dropdown_by_default_shows_all' do
    visit volunteers_path
    within 'tbody' do
      assert page.has_text? 'Akzeptiert'
      assert page.has_text? 'Angemeldet'
      assert page.has_text? 'Eingeladen'
      assert page.has_text? 'Abgelehnt'
      assert page.has_text? 'Beendet'
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
      refute page.has_text? 'Akzeptiert'
      refute page.has_text? 'Angemeldet'
      refute page.has_text? 'Eingeladen'
      refute page.has_text? 'Abgelehnt'
      assert page.has_text? 'Beendet'
    end
  end
end
