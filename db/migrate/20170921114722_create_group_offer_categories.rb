class CreateGroupOfferCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :group_offer_categories do |t|
      t.string :category_name
      t.string :category_state, default: 'active'

      t.datetime :deleted_at, index: true
      t.timestamps
    end

    change_table :group_offers do |t|
      t.references :group_offer_category, foreign_key: true, null: false
    end
  end
end
