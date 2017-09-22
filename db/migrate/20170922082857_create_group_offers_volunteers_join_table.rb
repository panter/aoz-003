class CreateGroupOffersVolunteersJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_table :group_offers_volunteers, id: false do |t|
      t.belongs_to :group_offer, index: true
      t.belongs_to :volunteer, index: true
    end
  end
end
