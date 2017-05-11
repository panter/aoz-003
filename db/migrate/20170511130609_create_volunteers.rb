class CreateVolunteers < ActiveRecord::Migration[5.1]
  def change
    create_table :volunteers do |t|
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :gender
      t.text :address
      t.string :nationality
      t.string :dual_nationality
      t.string :email
      t.string :phone
      t.string :profession
      t.text :education
      t.text :motivation
      t.boolean :experience
      t.text :expectations
      t.text :strengths
      t.text :skills
      t.text :interests
      t.string :state, default: 'interested/registered'
      t.string :duration
      t.boolean :man
      t.boolean :woman
      t.boolean :family
      t.boolean :kid
      t.boolean :sport
      t.boolean :creative
      t.boolean :music
      t.boolean :culture
      t.boolean :training
      t.boolean :german_course
      t.boolean :adults
      t.boolean :teenagers
      t.boolean :children
      t.boolean :city
      t.string :region
      t.timestamps
    end
  end
end
