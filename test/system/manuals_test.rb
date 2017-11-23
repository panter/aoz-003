require 'application_system_test_case'

class ManualsTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @manual = create :manual, user: @user
    @manual2 = create :manual, user: @user
  end

  test 'superadmin can see manuals on index' do
    login_as @user
    within 'nav' do
      click_link 'Anleitungen'
    end
    within 'tbody' do
      assert page.has_text? @manual.title
      assert page.has_text? @manual2.title
      # refute because there is no attachment uploaded so far
      refute page.has_selector?('table > tbody td:nth-child(5) i.glyphicon-paperclip')
    end
  end

  test 'superadmin can create a manual and attach a file' do
    login_as @user
    visit manuals_path
    click_link 'New Anleitung'
    select('category1', from: 'Kategorie')
    fill_in 'Titel', with: 'asdf'
    fill_in 'Beschreibung', with: 'asdf'
    #TODO attach a file
  end
end
