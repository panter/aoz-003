class AddAvailabilityToClients < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :flexible, :boolean, default: false
    add_column :clients, :morning, :boolean, default: false
    add_column :clients, :afternoon, :boolean, default: false
    add_column :clients, :evening, :boolean, default: false
    add_column :clients, :workday, :boolean, default: false
    add_column :clients, :weekend, :boolean, default: false
    add_column :clients, :detailed_description, :text
  end
end
