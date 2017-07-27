class AddEvaluationToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :evaluation, :boolean, default: false
  end
end
