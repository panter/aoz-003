class CreateVolunteersGroupOffersJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_table :volunteers_group_offers, id: false do |t|
      t.integer :volunteer_id, index: true
      t.integer :group_offer_id, index: true
    end
  end
end
