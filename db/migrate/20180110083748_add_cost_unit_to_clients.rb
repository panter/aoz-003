class AddCostUnitToClients < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :cost_unit, :integer
  end
end
