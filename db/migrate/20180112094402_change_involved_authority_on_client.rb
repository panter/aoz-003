class ChangeInvolvedAuthorityOnClient < ActiveRecord::Migration[5.1]
  def change
    remove_column :clients, :involved_authority
    add_reference :clients, :involved_authority, index: true, foreign_key: { to_table: :users }
  end
end
