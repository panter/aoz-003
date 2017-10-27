class GroupAssignmentUniquenessGroupOfferCombinedWithVolunteer < ActiveRecord::Migration[5.1]
  def change
    add_column :group_assignments, :active, :boolean, default: true
    add_index :group_assignments, [:volunteer_id, :group_offer_id, :active], unique: true,
      name: 'group_assignment_group_offer_volunteer'
  end
end
