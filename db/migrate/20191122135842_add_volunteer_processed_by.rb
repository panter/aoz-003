class AddVolunteerProcessedBy < ActiveRecord::Migration[5.1]
  def change
    change_table :volunteers do |t|
      t.references :invited_by
      t.references :accepted_by
      t.references :resigned_by
      t.references :rejected_by
      t.references :undecided_by
    end
  end
end
