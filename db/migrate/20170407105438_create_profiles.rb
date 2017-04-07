class CreateProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :profiles do |t|
      t.belongs_to :user, index: true, unique: true, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :picture
      t.string :address
      t.string :profession
      t.boolean :monday
      t.boolean :tuesday
      t.boolean :wednesday
      t.boolean :thursday
      t.boolean :friday
      t.timestamps
    end
  end
end
