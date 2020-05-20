require 'application_system_test_case'

class ClientsFilterDropdownsTest < ApplicationSystemTestCase
  def setup
    @user = create :user, role: 'superadmin'

    @accepted_woman_age_old = create(:client, acceptance: 'accepted', salutation: 'mrs',
      gender_request: 'woman', age_request: 'age_old')
    create :assignment_active, client: @accepted_woman_age_old

    @accepted_no_matter_age_old = create(:client, acceptance: 'accepted', salutation: 'mr',
      gender_request: 'no_matter', age_request: 'age_old')
    create :assignment_active, client: @accepted_no_matter_age_old

    @resigned_woman_age_middle = create(:client, acceptance: 'resigned', salutation: 'mrs',
      gender_request: 'woman', age_request: 'age_middle').contact.full_name
    @rejected_no_matter_age_middle = create(:client, acceptance: 'rejected', salutation: 'mr',
      gender_request: 'no_matter', age_request: 'age_middle').contact.full_name

    login_as @user
    visit clients_path
  end

  test 'filter_by_acceptance_works_and_disabling_works_as_well' do
    within '.section-navigation' do
      click_link 'Prozess'
      click_link 'Angemeldet'
    end
    visit current_url
    within 'tbody' do
      assert_text @accepted_woman_age_old
      assert_text @accepted_no_matter_age_old
      refute_text @resigned_woman_age_middle, wait: 0
      refute_text @rejected_no_matter_age_middle, wait: 0
    end
    within '.section-navigation' do
      click_link 'Prozess: Angemeldet'
      assert page.has_link? exact_text: 'Angemeldet', class: 'bg-success'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert_text @accepted_woman_age_old
      assert_text @accepted_no_matter_age_old
      assert_text @resigned_woman_age_middle
      assert_text @rejected_no_matter_age_middle
    end
  end

  test 'filter_acceptance_and_salutation_at_the_same_time' do
    within '.section-navigation' do
      click_link 'Anrede'
      click_link 'Herr'
    end
    visit current_url
    within '.section-navigation' do
      click_link 'Prozess'
      click_link 'Angemeldet'
    end
    visit current_url
    within 'tbody' do
      assert_text @accepted_no_matter_age_old
      refute_text @accepted_woman_age_old, wait: 0
      refute_text @resigned_woman_age_middle, wait: 0
      refute_text @rejected_no_matter_age_middle, wait: 0
    end
    within '.section-navigation' do
      click_link 'Anrede: Herr'
      assert page.has_link? 'Herr', class: 'bg-success'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert_text @accepted_woman_age_old
      assert_text @accepted_no_matter_age_old
      refute_text @resigned_woman_age_middle, wait: 0
      refute_text @rejected_no_matter_age_middle, wait: 0
    end
    click_link 'Filter aufheben'
    visit current_url
    within 'tbody' do
      assert_text @accepted_woman_age_old
      assert_text @accepted_no_matter_age_old
      assert_text @resigned_woman_age_middle
      assert_text @rejected_no_matter_age_middle
    end
  end

  test 'filter_acceptance_tandem_and_salutation_at_the_same_time' do
    within '.section-navigation' do
      click_link 'Prozess'
      click_link 'Angemeldet'
    end
    visit current_url
    within '.section-navigation' do
      click_link 'Einsatz'
      click_link 'Aktiv'
    end
    visit current_url
    within '.section-navigation' do
      click_link 'Anrede'
      click_link 'Frau'
    end
    visit current_url
    within 'tbody' do
      assert_text @accepted_woman_age_old
      refute_text @accepted_no_matter_age_old, wait: 0
      refute_text @resigned_woman_age_middle, wait: 0
      refute_text @rejected_no_matter_age_middle, wait: 0
    end
    within '.section-navigation' do
      click_link 'Anrede: Frau'
      assert page.has_link? text: 'Frau', class: 'bg-success'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert_text @accepted_woman_age_old
      assert_text @accepted_no_matter_age_old
      refute_text @resigned_woman_age_middle, wait: 0
      refute_text @rejected_no_matter_age_middle, wait: 0
    end
    click_link 'Filter aufheben'
    visit current_url
    within 'tbody' do
      assert_text @accepted_woman_age_old
      assert_text @accepted_no_matter_age_old
      assert_text @resigned_woman_age_middle
      assert_text @rejected_no_matter_age_middle
    end
  end

  test 'filter_find_client' do
    Assignment.destroy_all
    create :volunteer
    client_with_language_skills = create :client, :with_language_skills,
      age_request: 'age_young', gender_request: 'woman'

    login_as @user
    visit volunteers_path
    click_on 'Klient/in suchen', match: :first
    click_on 'Klient/in suchen'

    assert_button 'Geschlecht Freiwillige/r: Alle'
    assert_button 'Alter Freiwillige/r: Alle'
    assert_button 'Sprachkenntnisse: Alle'

    assert_text client_with_language_skills
    assert_text @accepted_woman_age_old
    assert_text @accepted_no_matter_age_old
    refute_text @resigned_woman_age_middle, wait: 0
    refute_text @rejected_no_matter_age_middle, wait: 0

    click_on 'Geschlecht Freiwillige/r: Alle'
    click_on 'Frau'

    assert_text client_with_language_skills
    assert_text @accepted_woman_age_old
    assert_text @accepted_no_matter_age_old
    refute_text @resigned_woman_age_middle, wait: 0
    refute_text @rejected_no_matter_age_middle, wait: 0

    click_on 'Alter Freiwillige/r: Alle'
    click_on '20 - 35'

    assert_text client_with_language_skills
    refute_text @accepted_woman_age_old, wait: 0
    refute_text @accepted_no_matter_age_old, wait: 0
    refute_text @resigned_woman_age_middle, wait: 0
    refute_text @rejected_no_matter_age_middle, wait: 0

    click_on 'Sprachkenntnisse: Alle'
    click_on client_with_language_skills.language_skills.first.language_name, match: :first
    wait_for_ajax
    assert_text client_with_language_skills
    refute_text @accepted_woman_age_old, wait: 0
    refute_text @accepted_no_matter_age_old, wait: 0
    refute_text @resigned_woman_age_middle, wait: 0
    refute_text @rejected_no_matter_age_middle, wait: 0
  end

  test 'filter find client availability' do
    Assignment.destroy_all
    create :volunteer
    client_flexible = create :client, flexible: true
    client_morning = create :client, morning: true
    client_flexible_morning = create :client, flexible: true, morning: true

    login_as @user
    visit volunteers_path
    click_on 'Klient/in suchen', match: :first
    click_on 'Klient/in suchen'

    assert_link 'Verfügbarkeit'

    assert_text client_flexible
    assert_text client_morning
    assert_text client_flexible_morning

    click_on 'Verfügbarkeit'
    click_on 'Flexibel'

    assert_text client_flexible
    assert_text client_flexible_morning
    refute_text client_morning, wait: 0

    # boolean_filter_dropdown chooses two values -> flexible & mornings
    click_on 'Verfügbarkeit'
    click_on 'Morgens'

    assert_text client_flexible_morning
    refute_text client_flexible, wait: 0
    refute_text client_morning, wait: 0

    # deselect flexible
    click_on 'Verfügbarkeit'
    click_on 'Flexibel'

    assert_text client_morning
    assert_text client_flexible_morning
    refute_text client_flexible, wait: 0
  end
end
