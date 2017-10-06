class AddGroupOffersToCertificates < ActiveRecord::Migration[5.1]
  def change
    add_column :certificates, :group_offer, :boolean, default: false
  end
end
