class AddDescriptionToGroupOfferCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :group_offer_categories, :description, :text
  end
end
