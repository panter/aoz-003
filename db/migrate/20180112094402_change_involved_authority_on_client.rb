class ChangeInvolvedAuthorityOnClient < ActiveRecord::Migration[5.1]
  def change
    change_table :clients do |t|
      t.remove :involved_authority
      t.belongs_to :involved_authority, references: :users, index: true
    end
  end
end
