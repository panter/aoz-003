class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients do |t|
      t.string :firstname
      t.string :lastname
      t.date :dob
      t.string :nationality
      t.string :permit
      t.string :gender
      t.string :street
      t.string :zip
      t.string :city
      t.string :phone
      t.string :email
      t.text :goals
      t.text :education
      t.text :hobbies
      t.text :interests
      t.string :state, default: 'registered'
      t.text :comments
      t.text :c_authority
      t.text :i_authority
      t.boolean :availability, default: false
      t.timestamps
    end
  end
end
