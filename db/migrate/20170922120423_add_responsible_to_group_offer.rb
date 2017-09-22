class AddResponsibleToGroupOffer < ActiveRecord::Migration[5.1]
  def change
    add_reference :group_offers, :responsible, index: true, foreign_key: { to_table: :volunteers }
  end
end
