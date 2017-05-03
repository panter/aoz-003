class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients do |t|
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
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
      t.text :competent_authority
      t.text :involved_authority
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
