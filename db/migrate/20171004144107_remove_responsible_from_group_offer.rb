class RemoveResponsibleFromGroupOffer < ActiveRecord::Migration[5.1]
  def change
    remove_reference :group_offers, :responsible, index: true, foreign_key: { to_table: :volunteers }
    remove_column :group_offers, :volunteer_responsible_state, :string
  end
end
