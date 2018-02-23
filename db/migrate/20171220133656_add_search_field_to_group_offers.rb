class AddSearchFieldToGroupOffers < ActiveRecord::Migration[5.1]
  def up
    add_column :group_offers, :search_volunteer, :string
    GroupOffer.find_each do |group_offer|
      group_offer.update_search_volunteers
    end
  end

  def down
    remove_column :group_offers, :search_volunteer
  end
end
