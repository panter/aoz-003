class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.string :title
      t.string :category0
      t.string :category1
      t.string :category2
      t.string :category3
      t.attachment :attachment

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
