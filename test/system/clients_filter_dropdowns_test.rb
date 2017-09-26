require 'application_system_test_case'

class ClientsFilterDropdownsTest < ApplicationSystemTestCase
  def setup
    @user = create :user, role: 'superadmin'
    client = create(:client, state: 'registered', salutation: 'mrs', gender_request: 'same',
      age_request: 'age_old')
    @registered_mrs_same_age_old = client.contact.full_name
    client = create(:client, state: 'active', salutation: 'mr', gender_request: 'no_matter',
      age_request: 'age_old')
    @active_mr_no_matter_age_old = client.contact.full_name
    client = create(:client, state: 'active', salutation: 'mrs', gender_request: 'same',
      age_request: 'age_middle')
    @active_mrs_same_age_middle = client.contact.full_name
    client = create(:client, state: 'registered', salutation: 'mr', gender_request: 'no_matter',
      age_request: 'age_middle')
    @registered_mr_no_matter_age_middle = client.contact.full_name
    login_as @user
    visit clients_path
  end

  test 'filter by state works and disabling works as well' do
    within '.section-navigation' do
      click_link 'State'
      click_link 'Registered'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @registered_mrs_same_age_old
      refute page.has_text? @active_mr_no_matter_age_old
    end
    within '.section-navigation' do
      click_link 'State: Registered'
      assert page.find('a.bg-success', text: 'Registered').present?
      click_link 'All'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @registered_mrs_same_age_old
      assert page.has_text? @active_mr_no_matter_age_old
    end
  end

  test 'Filter state and salutation at the same time' do
    within '.section-navigation' do
      click_link 'Salutation'
      click_link 'Mr.'
    end
    visit current_url
    within '.section-navigation' do
      click_link 'State'
      click_link 'Active'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @active_mr_no_matter_age_old
      refute page.has_text? @active_mrs_same_age_middle
      refute page.has_text? @registered_mr_no_matter_age_middle
    end
    within '.section-navigation' do
      click_link 'Salutation: Mr.'
      assert page.find('a.bg-success', text: 'Mr.').present?
      click_link 'All'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @active_mr_no_matter_age_old
      assert page.has_text? @active_mrs_same_age_middle
      refute page.has_text? @registered_mr_no_matter_age_middle
    end
    click_link 'Clear filters'
    visit current_url
    within 'tbody' do
      assert page.has_text? @active_mr_no_matter_age_old
      assert page.has_text? @active_mrs_same_age_middle
      assert page.has_text? @registered_mr_no_matter_age_middle
    end
  end

  test 'boolean filters for gender request and age_request' do
    within '.section-navigation' do
      click_link "Volunteer's gender"
      click_link 'gender same'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @registered_mrs_same_age_old
      refute page.has_text? @active_mr_no_matter_age_old
      assert page.has_text? @active_mrs_same_age_middle
      refute page.has_text? @registered_mr_no_matter_age_middle
    end
    within '.section-navigation' do
      click_link "Volunteer's age"
      click_link '36 - 50'
    end
    visit current_url
    within 'tbody' do
      refute page.has_text? @registered_mrs_same_age_old
      refute page.has_text? @active_mr_no_matter_age_old
      assert page.has_text? @active_mrs_same_age_middle
      refute page.has_text? @registered_mr_no_matter_age_middle
    end
    within '.section-navigation' do
      click_link "Volunteer's gender: gender same"
      assert page.find('a.bg-success', text: 'gender same').present?
      click_link 'gender same'
    end
    visit current_url
    within 'tbody' do
      refute page.has_text? @registered_mrs_same_age_old
      refute page.has_text? @active_mr_no_matter_age_old
      assert page.has_text? @active_mrs_same_age_middle
      assert page.has_text? @registered_mr_no_matter_age_middle
    end
    click_link 'Clear filters'
    visit current_url
    within 'tbody' do
      assert page.has_text? @registered_mrs_same_age_old
      assert page.has_text? @active_mr_no_matter_age_old
      assert page.has_text? @active_mrs_same_age_middle
      assert page.has_text? @registered_mr_no_matter_age_middle
    end
  end
end
