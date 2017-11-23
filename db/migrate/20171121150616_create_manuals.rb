class CreateManuals < ActiveRecord::Migration[5.1]
  def change
    create_table :manuals do |t|
      t.string :title
      t.text :description
      t.string :category
      t.attachment :attachment
      t.references :user, foreign_key: true
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
