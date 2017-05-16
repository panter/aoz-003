class CreateContactPoints < ActiveRecord::Migration[5.1]
  def change
    create_table :contact_points do |t|
      t.references :contact, foreign_key: true
      t.string :body
      t.string :label
      t.string :type

      t.timestamps
    end
  end
end
