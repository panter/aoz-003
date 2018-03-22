class AddGroupOfferOfferTypeDefault < ActiveRecord::Migration[5.1]
  def change
    change_table :group_offers do |t|
      t.change :offer_type, :string, null: false
      t.change_default :offer_type, 'internal_offer'
    end
  end
end
