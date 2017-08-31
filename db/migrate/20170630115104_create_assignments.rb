class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :assignments do |t|
      t.string :state

      t.references :client, foreign_key: true
      t.references :volunteer, foreign_key: true
      t.references :creator, references: :users

      t.datetime :deleted_at
      t.timestamps
    end

    add_foreign_key :assignments, :assignments, column: :creator_id
  end
end
