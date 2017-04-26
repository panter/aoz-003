class RemoveAvailabilityFromClients < ActiveRecord::Migration[5.1]
  def change
    remove_column :clients, :availability, :boolean
  end
end
