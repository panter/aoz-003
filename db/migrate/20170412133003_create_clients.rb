class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients do |t|
      t.date :birth_year
      t.date :entry_year
      t.string :state, default: 'registered'
      t.string :gender_request
      t.string :age_request
      t.string :other_request
      t.string :nationality
      t.string :permit
      t.string :salutation
      t.text :goals
      t.text :education
      t.text :interests
      t.text :comments
      t.text :competent_authority
      t.text :involved_authority
      t.text :actual_activities
      t.text :detailed_description, :text
      t.boolean :flexible, default: false
      t.boolean :morning, default: false
      t.boolean :afternoon, default: false
      t.boolean :evening, default: false
      t.boolean :workday, default: false
      t.boolean :weekend, default: false

      t.references :user, foreign_key: true

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
