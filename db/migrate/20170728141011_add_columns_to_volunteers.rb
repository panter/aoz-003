class AddColumnsToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :dancing, :boolean
    add_column :volunteers, :health, :boolean
    add_column :volunteers, :cooking, :boolean
    add_column :volunteers, :excursions, :boolean
    add_column :volunteers, :women, :boolean
    add_column :volunteers, :unaccompanied, :boolean
    add_column :volunteers, :zurich, :boolean
    add_column :volunteers, :other_offer, :boolean
    add_column :volunteers, :other_offer_desc, :text
    add_column :volunteers, :own_kids, :text
  end
end
