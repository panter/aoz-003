require 'application_system_test_case'

class GroupOfferFiltersTest < ApplicationSystemTestCase
  def setup
    @d1 = create :department
    @d2 = create :department
    @open_d1 = create(:group_offer, title: 'o1', offer_state: 'open', department: @d1)
    @full_d1 = create(:group_offer, title: 'f1', offer_state: 'full', department: @d1)
    @part_d1 = create(:group_offer, title: 'p1', offer_state: 'partially_occupied', department: @d1)
    @open_d2 = create(:group_offer, title: 'o2', offer_state: 'open', department: @d2)
    @full_d2 = create(:group_offer, title: 'f2', offer_state: 'full', department: @d2)
    @part_d2 = create(:group_offer, title: 'p2', offer_state: 'partially_occupied', department: @d2)
    login_as create(:user)
    visit group_offers_path
  end

  test 'filter by department' do
    within '.section-navigation' do
      click_link 'Department: All'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @open_d1.title
      assert page.has_text? @full_d1.title
      assert page.has_text? @part_d1.title
      assert page.has_text? @open_d2.title
      assert page.has_text? @full_d2.title
      assert page.has_text? @part_d2.title
    end
    within '.section-navigation' do
      click_link 'Department: All'
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
    within '.section-navigation' do
      click_link 'Offer state: All'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @open_d1.title
      assert page.has_text? @full_d1.title
      assert page.has_text? @part_d1.title
      assert page.has_text? @open_d2.title
      assert page.has_text? @full_d2.title
      assert page.has_text? @part_d2.title
    end
    within '.section-navigation' do
      click_link 'Offer state: All'
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

  test 'filter by department and state' do
    within '.section-navigation' do
      click_link 'Offer state: All'
      click_link 'Open'
    end
    visit current_url
    within '.section-navigation' do
      click_link 'Department: All'
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
    within '.section-navigation' do
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
  end
end
