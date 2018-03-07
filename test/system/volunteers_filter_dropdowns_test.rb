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
      click_link 'Affirmation: Not resigned'
      click_link 'Undecided'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? 'Undecided'
      refute page.has_text? 'Accepted'
    end
    within '.section-navigation' do
      click_link 'Affirmation: Undecided'
      assert page.has_link? text: 'Undecided', class: 'bg-undecided'
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
      click_link 'Affirmation: Not resigned'
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
      assert page.has_link? 'Mr.', class: 'bg-success'
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
    false_volunteer = create :volunteer, man: false, woman: false, morning: false, workday: false
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
      assert page.has_link? 'Man', class: 'bg-success'
      click_link 'Woman'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? Volunteer.where(woman: true).first.to_s
      refute page.has_text? false_volunteer.to_s
    end
    within '.section-navigation' do
      click_link 'Single accompaniment'
      assert page.has_link? 'Man', class: 'bg-success'
      assert page.has_link? 'Woman', class: 'bg-success'
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

  test 'Filter for group offer categories' do
    within '.section-navigation' do
      click_link 'Group offer categories'
      click_link @c1
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @volunteer1
      refute page.has_text? @volunteer2
      refute page.has_text? @volunteer3
    end
    within '.section-navigation' do
      click_link 'Group offer categories'
      click_link @c3
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @volunteer2
      refute page.has_text? @volunteer1
      refute page.has_text? @volunteer3
    end
    within '.section-navigation' do
      click_link 'Group offer categories'
      click_link @c2
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @volunteer1
      assert page.has_text? @volunteer2
      refute page.has_text? @volunteer3
    end
    click_link 'Clear filters'
    visit current_url
    within 'tbody' do
      assert page.has_text? @volunteer1
      assert page.has_text? @volunteer2
      assert page.has_text? @volunteer1
    end
  end

  test 'thead_acceptance_filter_dropdown_by_default_excludes_resigned' do
    visit volunteers_path
    within 'tbody' do
      assert page.has_text? 'Accepted'
      assert page.has_text? 'Undecided'
      assert page.has_text? 'Eingeladen'
      assert page.has_text? 'Rejected'
      refute page.has_text? 'Resigned'
    end
  end

  test 'choosing_acceptance_resigned_works' do
    visit volunteers_path
    within 'tbody' do
      refute page.has_text? 'Resigned'
    end
    within '.section-navigation' do
      click_link 'Affirmation: Not resigned'
      click_link 'Resigned'
    end
    visit current_url
    within 'tbody' do
      refute page.has_text? 'Accepted'
      refute page.has_text? 'Undecided'
      refute page.has_text? 'Eingeladen'
      refute page.has_text? 'Rejected'
      assert page.has_text? 'Resigned'
    end
  end
end
