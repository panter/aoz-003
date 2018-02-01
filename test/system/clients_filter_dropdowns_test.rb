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
      click_link 'Acceptance'
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
      click_link 'Acceptance'
      assert page.find('a.bg-accepted', text: 'Angemeldet').present?
      click_link 'All'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @accepted_mrs_same_age_old
      assert page.has_text? @accepted_mr_no_matter_age_old
      refute page.has_text? @resigned_mrs_same_age_middle
      assert page.has_text? @rejected_mr_no_matter_age_middle
    end
  end

  test 'filter_acceptance_and_salutation_at_the_same_time' do
    within '.section-navigation' do
      click_link 'Salutation'
      click_link 'Mr.'
    end
    visit current_url
    within '.section-navigation' do
      click_link 'Acceptance'
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
      click_link 'Salutation: Mr.'
      assert page.find('a.bg-success', text: 'Mr.').present?
      click_link 'All'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @accepted_mrs_same_age_old
      assert page.has_text? @accepted_mr_no_matter_age_old
      refute page.has_text? @resigned_mrs_same_age_middle
      refute page.has_text? @rejected_mr_no_matter_age_middle
    end
    click_link 'Clear filters'
    visit current_url
    within 'tbody' do
      assert page.has_text? @accepted_mrs_same_age_old
      assert page.has_text? @accepted_mr_no_matter_age_old
      refute page.has_text? @resigned_mrs_same_age_middle
      assert page.has_text? @rejected_mr_no_matter_age_middle
    end
  end

  test 'filter_acceptance_tandem_and_salutation_at_the_same_time' do
    within '.section-navigation' do
      click_link 'Acceptance'
      click_link 'Angemeldet'
    end
    visit current_url
    within '.section-navigation' do
      click_link 'Tandem'
      click_link 'Aktiv'
    end
    visit current_url
    within '.section-navigation' do
      click_link 'Salutation'
      click_link 'Mrs.'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @accepted_mrs_same_age_old
      refute page.has_text? @accepted_mr_no_matter_age_old
      refute page.has_text? @resigned_mrs_same_age_middle
      refute page.has_text? @rejected_mr_no_matter_age_middle
    end
    within '.section-navigation' do
      click_link 'Salutation: Mrs.'
      assert page.find('a.bg-success', text: 'Mrs.').present?
      click_link 'All'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @accepted_mrs_same_age_old
      assert page.has_text? @accepted_mr_no_matter_age_old
      refute page.has_text? @resigned_mrs_same_age_middle
      refute page.has_text? @rejected_mr_no_matter_age_middle
    end
    click_link 'Clear filters'
    visit current_url
    within 'tbody' do
      assert page.has_text? @accepted_mrs_same_age_old
      assert page.has_text? @accepted_mr_no_matter_age_old
      refute page.has_text? @resigned_mrs_same_age_middle
      assert page.has_text? @rejected_mr_no_matter_age_middle
    end
  end
end
