class RemoveMistakenTerminationFieldsFromGroupOffersTable < ActiveRecord::Migration[5.1]
  def change
    change_table :group_offers do |t|
      t.remove_references :termination_verified_by, references: :users
      t.remove :termination_verified_at
    end
  end
end
