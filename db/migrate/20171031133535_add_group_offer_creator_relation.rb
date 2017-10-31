class AddGroupOfferCreatorRelation < ActiveRecord::Migration[5.1]
  def change
    change_table :group_offers do |t|
      t.belongs_to :user
    end
  end
end
