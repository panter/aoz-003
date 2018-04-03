class RemoveTitleFromContact < ActiveRecord::Migration[5.1]
  def change
    remove_column :contacts, :title
  end
end
