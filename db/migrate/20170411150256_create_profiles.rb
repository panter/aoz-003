class CreateProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :profiles do |t|
      t.string :profession
      t.text :detailed_description

      t.boolean :flexible, default: false
      t.boolean :morning, default: false
      t.boolean :afternoon, default: false
      t.boolean :evening, default: false
      t.boolean :workday, default: false
      t.boolean :weekend, default: false

      t.attachment :avatar
      t.references :user, foreign_key: true
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
