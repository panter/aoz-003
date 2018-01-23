require 'application_system_test_case'

class GroupOfferFiltersTest < ApplicationSystemTestCase
  def setup
    @d1 = create :department
    @d2 = create :department
    @c1 = create :group_offer_category
    @c2 = create :group_offer_category
    @open_d1 = create(:group_offer, title: 'o1', offer_state: 'open', department: @d1,
      group_offer_category: @c1)
    @full_d1 = create(:group_offer, title: 'f1', offer_state: 'full', department: @d1,
      group_offer_category: @c2)
    @part_d1 = create(:group_offer, title: 'p1', offer_state: 'partially_occupied', department: @d1,
      group_offer_category: @c1)
    @open_d2 = create(:group_offer, title: 'o2', offer_state: 'open', department: @d2,
      group_offer_category: @c2)
    @full_d2 = create(:group_offer, title: 'f2', offer_state: 'full', department: @d2,
      group_offer_category: @c1)
    @part_d2 = create(:group_offer, title: 'p2', offer_state: 'partially_occupied', department: @d2,
      group_offer_category: @c2)
    login_as create(:user)
    visit group_offers_path
    within 'tbody' do
      assert page.has_text? @open_d1.title
      assert page.has_text? @full_d1.title
      assert page.has_text? @part_d1.title
      assert page.has_text? @open_d2.title
      assert page.has_text? @full_d2.title
      assert page.has_text? @part_d2.title
    end
  end

  test 'filter by department' do
    within '.section-navigation#filters' do
      click_link 'Department'
      click_link @d1.to_s
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @open_d1.title
      assert page.has_text? @full_d1.title
      assert page.has_text? @part_d1.title
      refute page.has_text? @open_d2.title
      refute page.has_text? @full_d2.title
      refute page.has_text? @part_d2.title
    end
  end

  test 'filter by state' do
    within '.section-navigation#filters' do
      click_link 'Offer state'
      click_link 'Open'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @open_d1.title
      refute page.has_text? @full_d1.title
      refute page.has_text? @part_d1.title
      assert page.has_text? @open_d2.title
      refute page.has_text? @full_d2.title
      refute page.has_text? @part_d2.title
    end
  end

  test 'filter_by_category' do
    within '.section-navigation#filters' do
      click_link 'Kategorie'
      click_link @c1.to_s
    end
    visit current_url
    within '.section-navigation#filters' do
      assert page.has_link? "Kategorie: #{@c1.to_s}"
    end
    within 'tbody' do
      assert page.has_text? @open_d1.title
      refute page.has_text? @full_d1.title
      assert page.has_text? @part_d1.title
      refute page.has_text? @open_d2.title
      assert page.has_text? @full_d2.title
      refute page.has_text? @part_d2.title
    end
  end

  test 'filter_by_department_state_and_category' do
    within '.section-navigation#filters' do
      click_link 'Offer state'
      click_link 'Open'
    end
    visit current_url
    within '.section-navigation#filters' do
      click_link 'Department'
      click_link @d1.to_s
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @open_d1.title
      refute page.has_text? @full_d1.title
      refute page.has_text? @part_d1.title
      refute page.has_text? @open_d2.title
      refute page.has_text? @full_d2.title
      refute page.has_text? @part_d2.title
    end
    within '.section-navigation#filters' do
      click_link 'Offer state: Open'
      click_link 'All'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @open_d1.title
      assert page.has_text? @full_d1.title
      assert page.has_text? @part_d1.title
      refute page.has_text? @open_d2.title
      refute page.has_text? @full_d2.title
      refute page.has_text? @part_d2.title
    end
    within '.section-navigation#filters' do
      click_link 'Kategorie'
      click_link @c2.to_s
    end
    visit current_url
    within 'tbody' do
      refute page.has_text? @open_d1.title
      assert page.has_text? @full_d1.title
      refute page.has_text? @part_d1.title
      refute page.has_text? @open_d2.title
      refute page.has_text? @full_d2.title
      refute page.has_text? @part_d2.title
    end
  end
end
