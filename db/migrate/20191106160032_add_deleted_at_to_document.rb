class AddDeletedAtToDocument < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :deleted_at, :datetime
    add_index :documents, :deleted_at
  end
end
