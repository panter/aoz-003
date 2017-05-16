class CreateContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :street
      t.string :extended
      t.string :postal_code
      t.string :city
      t.references :contactable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
