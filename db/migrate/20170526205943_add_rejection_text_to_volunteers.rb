class AddRejectionTextToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :rejection_text, :text
  end
end
