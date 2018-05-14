class AddCommentsToGroupOffers < ActiveRecord::Migration[5.1]
  def change
    add_column :group_offers, :comments, :text
  end
end
