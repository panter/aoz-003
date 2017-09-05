class AddAnticipatedAssignmentTypeField < ActiveRecord::Migration[5.1]
  def change
    change_table :assignments do |t|
      t.string :kind, default: 'accompaniment'
    end
    change_column_default :assignments, :state, from: nil, to: 'suggested'
  end
end
