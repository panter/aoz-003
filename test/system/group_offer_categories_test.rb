require 'application_system_test_case'

class GroupOfferCategoriesTest < ApplicationSystemTestCase
  def setup
    @user = create :user
  end

  test 'superadmin can create new group offer' do
    login_as @user
    visit group_offers_path
    click_link 'Gruppenangebot Kategorien'
    assert page.has_text? 'Gruppenangebot Kategorien'
    click_link 'Gruppenangebot Kategorie erfassen'

    fill_in 'Name', with: 'Nähen'
    assert page.has_checked_field?('group_offer_category_category_state_active')
    click_button 'Gruppenangebot Kategorie erfassen'

    assert page.has_text? 'Gruppenangebot Kategorie wurde erfolgreich erstellt.'

    assert page.has_text? 'Name'
    assert page.has_text? 'Nähen'
    assert page.has_text? 'Status'
    assert page.has_text? 'Aktiv'
  end

  test 'superadmin can update a category' do
    create :group_offer_category, category_name: 'Schwimmen'
    login_as @user
    visit group_offer_categories_path

    assert page.has_text? 'Schwimmen'
    click_link 'Bearbeiten'
    fill_in 'Name', with: 'Schwimmkurs für Anfänger'
    page.choose('group_offer_category_category_state_inactive')
    click_button 'Gruppenangebot Kategorie aktualisieren'
    assert page.has_text? 'Gruppenangebot Kategorie wurde erfolgreich geändert.'
    assert page.has_text? 'Schwimmkurs für Anfänger'
    assert page.has_text? 'Inaktiv'
  end
end
