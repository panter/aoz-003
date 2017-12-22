class ChangeClientStateToAcceptance < ActiveRecord::Migration[5.1]
  def change
    change_table :clients do |t|
      t.integer :acceptance, default: 0
      t.boolean :active, default: false
    end
  end

  def up
    remove_column :clients, :state
  end

  def down
    add_column :clients, :state, :string, default: 'registered'
  end
end
