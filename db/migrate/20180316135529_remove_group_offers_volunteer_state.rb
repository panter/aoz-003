class RemoveGroupOffersVolunteerState < ActiveRecord::Migration[5.1]
  def change
    remove_column :group_offers, :volunteer_state
  end
end
