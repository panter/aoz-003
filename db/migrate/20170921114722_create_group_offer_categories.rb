class CreateGroupOfferCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :group_offer_categories do |t|
      t.string :category_name
      t.string :category_state, default: 'active'
      t.belongs_to :group_offers, foreign_key: true

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
