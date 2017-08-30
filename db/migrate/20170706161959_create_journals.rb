class CreateJournals < ActiveRecord::Migration[5.1]
  def change
    create_table :journals do |t|
      t.string :subject
      t.string :category
      t.text :body

      t.references :user, index: true, foreign_key: true
      t.references :journalable, polymorphic: true, index: true

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
