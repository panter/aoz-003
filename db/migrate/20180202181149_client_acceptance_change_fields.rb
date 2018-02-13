class ClientAcceptanceChangeFields < ActiveRecord::Migration[5.1]
  def change
    change_table :clients do |t|
      t.remove :resigned_on
      t.datetime :resigned_at
      t.datetime :accepted_at
      t.datetime :rejected_at
    end
  end
end
