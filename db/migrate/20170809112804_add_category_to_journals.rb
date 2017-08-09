class AddCategoryToJournals < ActiveRecord::Migration[5.1]
  def change
    add_column :journals, :category, :string
  end
end
