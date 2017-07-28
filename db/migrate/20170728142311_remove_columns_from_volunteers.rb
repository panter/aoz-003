class RemoveColumnsFromVolunteers < ActiveRecord::Migration[5.1]
  def change
    remove_column :volunteers, :duration, :string
    remove_column :volunteers, :region, :string
    remove_column :volunteers, :region_specific, :string
    remove_column :volunteers, :adults, :boolean
  end
end
