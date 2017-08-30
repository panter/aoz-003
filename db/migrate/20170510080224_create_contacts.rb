class CreateContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :contacts do |t|
      t.string :title
      t.string :first_name
      t.string :last_name
      t.string :street
      t.string :extended
      t.string :postal_code
      t.string :city
      t.string :primary_email
      t.string :primary_phone
      t.string :secondary_phone

      t.references :contactable, polymorphic: true, index: true

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
