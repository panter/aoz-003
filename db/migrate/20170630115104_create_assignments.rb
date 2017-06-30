class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :assignments do |t|
      t.references :client, foreign_key: true
      t.references :volunteer, foreign_key: true
      t.attachment :agreement
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
