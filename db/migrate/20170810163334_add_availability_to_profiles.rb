class AddAvailabilityToProfiles < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :flexible, :boolean, default: false
    add_column :profiles, :morning, :boolean, default: false
    add_column :profiles, :afternoon, :boolean, default: false
    add_column :profiles, :evening, :boolean, default: false
    add_column :profiles, :workday, :boolean, default: false
    add_column :profiles, :weekend, :boolean, default: false
    add_column :profiles, :detailed_description, :text
  end
end
