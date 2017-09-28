class AddActiveToGroupOffer < ActiveRecord::Migration[5.1]
  def change
    add_column :group_offers, :active, :boolean, default: true
  end
end
