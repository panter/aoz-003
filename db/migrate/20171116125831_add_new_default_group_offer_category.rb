class AddNewDefaultGroupOfferCategory < ActiveRecord::Migration[5.1]
  def change
    GroupOfferCategory.find_or_create_by(category_name: 'Kurzbegleitungen bei Wohnungsbezug in Zürich-Stadt')
  end
end

