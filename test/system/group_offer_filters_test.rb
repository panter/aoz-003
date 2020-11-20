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
    @active = create(:group_offer, title: 'active_group_offer', department: @d1,
      group_offer_category: @c2, active: true)
    @inactive = create(:group_offer, title: 'inactive_group_offer', department: @d2,
      group_offer_category: @c2, active: false)

    login_as create(:user)
    visit group_offers_path
    within 'tbody' do
      assert page.has_text? @open_d1.title
      assert page.has_text? @full_d1.title
      assert page.has_text? @part_d1.title
      assert page.has_text? @open_d2.title
      assert page.has_text? @full_d2.title
      assert page.has_text? @part_d2.title
      assert page.has_text? @active.title
      assert page.has_text? @inactive.title
    end
  end

  test 'filter by department' do
    within '.section-navigation#filters' do
      click_link 'Standort'
      click_link @d1.to_s
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @open_d1.title
      assert page.has_text? @full_d1.title
      assert page.has_text? @part_d1.title
      refute page.has_text? @open_d2.title, wait: 0
      refute page.has_text? @full_d2.title, wait: 0
      refute page.has_text? @part_d2.title, wait: 0
    end
  end

  test 'filter by offer state' do
    within '.section-navigation#filters' do
      click_link 'FW-Nachfrage'
      click_link 'Offen'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @open_d1.title
      refute page.has_text? @full_d1.title, wait: 0
      refute page.has_text? @part_d1.title, wait: 0
      assert page.has_text? @open_d2.title
      refute page.has_text? @full_d2.title, wait: 0
      refute page.has_text? @part_d2.title, wait: 0
    end
  end

  test 'filter_by_category' do
    within '.section-navigation#filters' do
      click_link 'Kategorie'
      click_link @c1.to_s
    end
    visit current_url
    within '.section-navigation#filters' do
      assert page.has_link? "Kategorie: #{@c1}"
    end
    within 'tbody' do
      assert page.has_text? @open_d1.title
      refute page.has_text? @full_d1.title, wait: 0
      assert page.has_text? @part_d1.title
      refute page.has_text? @open_d2.title, wait: 0
      assert page.has_text? @full_d2.title
      refute page.has_text? @part_d2.title, wait: 0
    end
  end

  test 'filter_by_department_state_and_category' do
    within '.section-navigation#filters' do
      click_link 'FW-Nachfrage'
      click_link 'Offen'
    end
    visit current_url
    within '.section-navigation#filters' do
      click_link 'Standort'
      click_link @d1.to_s
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @open_d1.title
      refute page.has_text? @full_d1.title, wait: 0
      refute page.has_text? @part_d1.title, wait: 0
      refute page.has_text? @open_d2.title, wait: 0
      refute page.has_text? @full_d2.title, wait: 0
      refute page.has_text? @part_d2.title, wait: 0
    end
    within '.section-navigation#filters' do
      click_link 'FW-Nachfrage: Offen'
      click_link 'Alle'
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @open_d1.title
      assert page.has_text? @full_d1.title
      assert page.has_text? @part_d1.title
      refute page.has_text? @open_d2.title, wait: 0
      refute page.has_text? @full_d2.title, wait: 0
      refute page.has_text? @part_d2.title, wait: 0
    end
    within '.section-navigation#filters' do
      click_link 'Kategorie'
      click_link @c2.to_s
    end
    visit current_url
    within 'tbody' do
      assert page.has_text? @full_d1.title
      refute page.has_text? @open_d1.title, wait: 0
      refute page.has_text? @part_d1.title, wait: 0
      refute page.has_text? @open_d2.title, wait: 0
      refute page.has_text? @full_d2.title, wait: 0
      refute page.has_text? @part_d2.title, wait: 0
    end
  end

  test 'filter by status active' do
    within '.section-navigation#filters' do
      click_link 'Status'
      click_link 'Aktiv'
    end
    visit current_url
    within 'tbody' do
      assert_text @active.title
      refute_text @inactive.title, wait: 0
    end
  end

  test 'filter by status inactive' do
    within '.section-navigation#filters' do
      click_link 'Status'
      click_link 'Inaktiv'
    end
    visit current_url
    within 'tbody' do
      assert_text @inactive.title
      assert page.has_css?('tr', text: 'active_group_offer', visible: false)
    end
  end

  test 'filter by offer type internal/external' do
    @internal = create(:group_offer)
    @external = create(:group_offer, :external)

    # filter for intern
    within '.section-navigation#filters' do
      click_link 'Intern/Extern'
      click_link 'Intern'
    end
    visit current_url
    within 'tbody' do
      assert_text @internal.title
      refute_text @external.title, wait: 0
    end

    # filter for extern
    within '.section-navigation#filters' do
      click_link 'Intern/Extern'
      click_link 'Extern'
    end
    visit current_url
    within 'tbody' do
      assert_text @external.title
      refute_text @internal.title, wait: 0
    end
  end
end
