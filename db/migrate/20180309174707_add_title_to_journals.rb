class AddTitleToJournals < ActiveRecord::Migration[5.1]
  def change
    change_table :journals do |t|
      t.string :title
    end
  end
end
