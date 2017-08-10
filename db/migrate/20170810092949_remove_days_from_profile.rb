class RemoveDaysFromProfile < ActiveRecord::Migration[5.1]
  def change
    remove_column :profiles, :monday, :boolean
    remove_column :profiles, :tuesday, :boolean
    remove_column :profiles, :wednesday, :boolean
    remove_column :profiles, :thursday, :boolean
    remove_column :profiles, :friday, :boolean
  end
end
