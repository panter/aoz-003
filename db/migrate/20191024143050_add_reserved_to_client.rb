class AddReservedToClient < ActiveRecord::Migration[5.1]
  def change
    change_table :clients do |t|
      t.bigint :reserved_by_id, index: true
      t.datetime :reserved_at
    end
  end
end