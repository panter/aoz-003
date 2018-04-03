class AddGroupOfferOfferTypeDefault < ActiveRecord::Migration[5.1]
  def up
    change_column :group_offers, :offer_type, :string, null: false, default: 'internal_offer'
  end

  def down
    change_column :group_offers, :offer_type, :string, null: true, default: nil
  end
end
