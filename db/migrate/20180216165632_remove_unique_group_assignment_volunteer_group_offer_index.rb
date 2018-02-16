class RemoveUniqueGroupAssignmentVolunteerGroupOfferIndex < ActiveRecord::Migration[5.1]
  def up
    remove_index :group_assignments, name: :group_assignment_group_offer_volunteer
    remove_column :group_assignments, :active
  end

  def down
    add_column :group_assignments, :active, :boolean, default: true
    add_index :group_assignments, [:volunteer_id, :group_offer_id, :active], unique: true,
      name: 'group_assignment_group_offer_volunteer'
  end
end
