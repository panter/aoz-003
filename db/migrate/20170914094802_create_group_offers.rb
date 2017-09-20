class CreateGroupOffers < ActiveRecord::Migration[5.1]
  def change
    create_table :group_offers do |t|
      t.string :title
      t.string :offer_type
      t.string :offer_state
      t.string :volunteer_state
      t.integer :necessary_volunteers
      t.string :volunteer_responsible_state
      t.text :description
      t.boolean :women, default: false
      t.boolean :men, default: false
      t.boolean :children, default: false
      t.boolean :teenagers, default: false
      t.boolean :unaccompanied, default: false
      t.boolean :all, default: false
      t.boolean :long_term, default: false
      t.boolean :regular, default: false
      t.boolean :short_term, default: false
      t.boolean :workday, default: false
      t.boolean :weekend, default: false
      t.boolean :flexible, default: false
      t.boolean :morning, default: false
      t.boolean :afternoon, default: false
      t.boolean :evening, default: false
      t.text :date_time
      t.datetime :deleted_at, index: true
      t.string :organization
      t.string :location
      t.belongs_to :department, foreign_key: true

      t.timestamps
    end
  end
end
