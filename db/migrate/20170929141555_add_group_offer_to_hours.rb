class AddGroupOfferToHours < ActiveRecord::Migration[5.1]
  def change
    change_table :hours do |t|
      t.belongs_to :group_offer
    end
  end
end
