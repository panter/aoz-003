class AddReservedToClient < ActiveRecord::Migration[5.1]
  def change
  	add_column :clients, :reserved_by, :bigint, index: true
  end
end
