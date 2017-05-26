class AddRejectionTypeToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :rejection_type, :string
  end
end
