class CreateJoinTableGroupOfferCategoriesVolunteers < ActiveRecord::Migration[5.1]
  def change
    create_join_table :group_offer_categories, :volunteers do |t|
      t.index [:group_offer_category_id, :volunteer_id], name: 'index_group_offer_on_volunteer'
      t.datetime :deleted_at, index: true
      t.timestamp
    end
  end
end
