require 'application_system_test_case'

class VolunteersFilterDropdownsTest < ApplicationSystemTestCase
  def setup
    #TODO
    #fix filters
    @user = create :user, role: 'superadmin'
    Volunteer.acceptance_collection.map do |acceptance|
      [
        create(:volunteer, acceptance: acceptance, man: true, training: true,
          morning: true, salutation: 'mrs'),
        create(:volunteer, acceptance: acceptance, man: true, woman: true, sport: true,
          workday: true, salutation: 'mr')
      ]
    end
    login_as @user
    visit volunteers_path
  end

  test 'filter by acceptance works and disabling works as well' do
    within '.section-navigation' do
      click_link 'Acceptance'
      click_link 'Undecided'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? 'Undecided'
      refute page.has_text? 'Accepted'
    end
    within '.section-navigation' do
      click_link 'Acceptance'
      assert page.find('a.bg-success', text: 'Undecided').present?
      click_link 'All'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? 'Accepted'
      assert page.has_text? 'Undecided'
    end
  end

  test 'Filter acceptance and salutation at the same time' do
    within '.section-navigation' do
      click_link 'Salutation'
      click_link 'Mr.'
    end
    visit current_url
    within '.section-navigation' do
      click_link 'Acceptance'
      click_link 'Accepted'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? 'Mr.'
      refute page.has_text? 'Mrs.'
      assert page.has_text? 'Accepted'
      refute page.has_text? 'Rejected'
    end
    within '.section-navigation' do
      click_link 'Salutation: Mr.'
      assert page.find('a.bg-success', text: 'Mr.').present?
      click_link 'All'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? 'Mrs.'
      assert page.has_text? 'Mr.'
      assert page.has_text? 'Accepted'
      refute page.has_text? 'Rejected'
    end
    click_link 'Clear filters'
    visit current_url
    within 'tbody' do
      assert page.has_text? 'Mrs.'
      assert page.has_text? 'Mr.'
      assert page.has_text? 'Accepted'
      assert page.has_text? 'Rejected'
    end
  end

  test 'boolean filters for single accompainment' do
    false_volunteer = create :volunteer, man: false, woman: false, sport: false, training: false,
      morning: false, workday: false
    within '.section-navigation' do
      click_link 'Single accompaniment'
      click_link 'Man'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? Volunteer.where(man: true).first.to_s
      refute page.has_text? false_volunteer.to_s
    end
    within '.section-navigation' do
      click_link 'Single accompaniment'
      assert page.find('a.bg-success', text: 'Man').present?
      click_link 'Woman'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? Volunteer.where(woman: true).first.to_s
      refute page.has_text? false_volunteer.to_s
    end
    within '.section-navigation' do
      click_link 'Single accompaniment'
      assert page.find('a.bg-success', text: 'Man').present?
      assert page.find('a.bg-success', text: 'Woman').present?
      click_link 'Woman'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? Volunteer.where(man: true, woman: false).first.to_s
    end
    click_link 'Clear filters'
    visit current_url
    within 'tbody' do
      assert page.has_text? false_volunteer.to_s
    end
  end
end
