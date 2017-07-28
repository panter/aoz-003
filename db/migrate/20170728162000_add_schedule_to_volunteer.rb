class AddScheduleToVolunteer < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :flexible, :boolean, default: false
    add_column :volunteers, :morning, :boolean, default: false
    add_column :volunteers, :afternoon, :boolean, default: false
    add_column :volunteers, :evening, :boolean, default: false
    add_column :volunteers, :workday, :boolean, default: false
    add_column :volunteers, :weekend, :boolean, default: false
    add_column :volunteers, :detailed_description, :text
  end
end
