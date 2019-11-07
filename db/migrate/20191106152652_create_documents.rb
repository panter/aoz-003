class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.attachment :file
      t.string :title, default: '', null: false
      t.string :category1
      t.string :category2
      t.string :category3
      t.string :category4
      t.timestamps
    end
  end
end
