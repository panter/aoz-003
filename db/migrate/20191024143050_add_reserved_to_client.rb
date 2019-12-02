class AddReservedToClient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :reserved_by, :bigint, index: true
    add_column :clients, :reserved_at, :datetime
  end
end