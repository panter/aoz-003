class AddDefaultGroupOfferCategories < ActiveRecord::Migration[5.1]
  def change
    [
      'Sport', 'Kreativ', 'Musik', 'Kultur', 'Bildung', 'Deutsch-Kurs',
      'Schreibdienst für Wohnungssuchende', 'Hausaufgabenhilfe', 'Bewerbungswerkstatt', 'Freizeit',
      'Kinderbetreuung', 'Fussballnachmittag', 'Nähen'
    ].each do |category_name|
      GroupOfferCategory.find_or_create_by(category_name: category_name)
    end
  end
end
