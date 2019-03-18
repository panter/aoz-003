class AddReactivatedByFields < ActiveRecord::Migration[5.1]
  def change
    change_table :clients do |t|
      t.references :reactivated_by, references: :users, index: true
      t.datetime :reactivated_at
    end

    change_table :volunteers do |t|
      t.references :reactivated_by, references: :users, index: true
      t.datetime :reactivated_at
    end

    change_table :assignments do |t|
      t.references :reactivated_by, references: :users, index: true
      t.datetime :reactivated_at
    end

    change_table :assignment_logs do |t|
      t.references :reactivated_by, references: :users, index: true
      t.datetime :reactivated_at
    end

    change_table :group_assignments do |t|
      t.references :reactivated_by, references: :users, index: true
      t.datetime :reactivated_at
    end

    change_table :group_assignment_logs do |t|
      t.references :reactivated_by, references: :users, index: true
      t.datetime :reactivated_at
    end
  end
end
