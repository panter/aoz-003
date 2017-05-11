class CreateVolunteers < ActiveRecord::Migration[5.1]
  def change
    create_table :volunteers do |t|
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :street
      t.string :zip
      t.string :city
      t.string :email
      t.string :phone
      t.string :nationality
      t.string :profession
      t.text :education
      t.text :skills
      t.text :motivation
      t.boolean :experience
      t.text :strengths
      t.text :expectations
      t.text :interests
      t.boolean :expenses
      t.string :state, default: 'interested/registered'
      t.boolean :man
      t.boolean :woman
      t.boolean :family
      t.boolean :kid
      t.boolean :group_course
      t.text :other_support
      t.string :duration
      t.boolean :one_time_support
      t.boolean :short_term_support
      t.boolean :group
      t.boolean :course
      t.boolean :support_city
      t.boolean :region
      t.boolean :canton

      t.timestamps
    end
  end
end
