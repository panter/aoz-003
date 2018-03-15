require 'application_system_test_case'

class ClientsFilterDropdownsTest < ApplicationSystemTestCase
  def setup
    @user = create :user, role: 'superadmin'
    @accepted_mrs_same_age_old = create(:client, acceptance: 'accepted', salutation: 'mrs',
      gender_request: 'same', age_request: 'age_old')
    create :assignment_active, client: @accepted_mrs_same_age_old
    @accepted_mrs_same_age_old = @accepted_mrs_same_age_old.contact.full_name
    @accepted_mr_no_matter_age_old = create(:client, acceptance: 'accepted', salutation: 'mr',
      gender_request: 'no_matter', age_request: 'age_old')
    create :assignment_active, client: @accepted_mr_no_matter_age_old
    @accepted_mr_no_matter_age_old = @accepted_mr_no_matter_age_old.contact.full_name
    @resigned_mrs_same_age_middle = create(:client, acceptance: 'resigned', salutation: 'mrs',
      gender_request: 'same', age_request: 'age_middle').contact.full_name
    @rejected_mr_no_matter_age_middle = create(:client, acceptance: 'rejected', salutation: 'mr',
      gender_request: 'no_matter', age_request: 'age_middle').contact.full_name
    login_as @user
    visit clients_path
  end

  test 'filter_by_acceptance_works_and_disabling_works_as_well' do
    within '.section-navigation' do
      click_link 'Affirmation'
      click_link 'Angemeldet'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @accepted_mrs_same_age_old
      assert page.has_text? @accepted_mr_no_matter_age_old
      refute page.has_text? @resigned_mrs_same_age_middle
      refute page.has_text? @rejected_mr_no_matter_age_middle
    end
    within '.section-navigation' do
      click_link 'Affirmation: Angemeldet'
      assert page.has_link? text: 'Angemeldet', class: 'bg-accepted'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @accepted_mrs_same_age_old
      assert page.has_text? @accepted_mr_no_matter_age_old
      assert page.has_text? @resigned_mrs_same_age_middle
      assert page.has_text? @rejected_mr_no_matter_age_middle
    end
  end

  test 'filter_acceptance_and_salutation_at_the_same_time' do
    within '.section-navigation' do
      click_link 'Anrede'
      click_link 'Herr'
    end
    visit current_url
    within '.section-navigation' do
      click_link 'Affirmation'
      click_link 'Angemeldet'
    end
    visit current_url
    within 'tbody' do
      refute page.has_text? @accepted_mrs_same_age_old
      assert page.has_text? @accepted_mr_no_matter_age_old
      refute page.has_text? @resigned_mrs_same_age_middle
      refute page.has_text? @rejected_mr_no_matter_age_middle
    end
    within '.section-navigation' do
      click_link 'Anrede: Herr'
      assert page.has_link? 'Herr', class: 'bg-success'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @accepted_mrs_same_age_old
      assert page.has_text? @accepted_mr_no_matter_age_old
      refute page.has_text? @resigned_mrs_same_age_middle
      refute page.has_text? @rejected_mr_no_matter_age_middle
    end
    click_link 'Filter aufheben'
    visit current_url
    within 'tbody' do
      assert page.has_text? @accepted_mrs_same_age_old
      assert page.has_text? @accepted_mr_no_matter_age_old
      assert page.has_text? @resigned_mrs_same_age_middle
      assert page.has_text? @rejected_mr_no_matter_age_middle
    end
  end

  test 'filter_acceptance_tandem_and_salutation_at_the_same_time' do
    within '.section-navigation' do
      click_link 'Affirmation'
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
      assert page.has_text? @accepted_mrs_same_age_old
      refute page.has_text? @accepted_mr_no_matter_age_old
      refute page.has_text? @resigned_mrs_same_age_middle
      refute page.has_text? @rejected_mr_no_matter_age_middle
    end
    within '.section-navigation' do
      click_link 'Anrede: Frau'
      assert page.has_link? text: 'Frau', class: 'bg-success'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @accepted_mrs_same_age_old
      assert page.has_text? @accepted_mr_no_matter_age_old
      refute page.has_text? @resigned_mrs_same_age_middle
      refute page.has_text? @rejected_mr_no_matter_age_middle
    end
    click_link 'Filter aufheben'
    visit current_url
    within 'tbody' do
      assert page.has_text? @accepted_mrs_same_age_old
      assert page.has_text? @accepted_mr_no_matter_age_old
      assert page.has_text? @resigned_mrs_same_age_middle
      assert page.has_text? @rejected_mr_no_matter_age_middle
    end
  end
end
