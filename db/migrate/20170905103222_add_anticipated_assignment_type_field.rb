class AddAnticipatedAssignmentTypeField < ActiveRecord::Migration[5.1]
  def change
    change_table :assignments do |t|
      t.string :kind, default: 'accompaniment'
      t.rename :assignment_start, :period_start
      t.rename :assignment_end, :period_end
      t.change_default :state, from: nil, to: 'suggested'
    end
  end
end
