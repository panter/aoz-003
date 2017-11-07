class ContactFullNameField < ActiveRecord::Migration[5.1]
  def change
    change_table :contacts do |t|
      t.string :full_name
    end
  end
end
