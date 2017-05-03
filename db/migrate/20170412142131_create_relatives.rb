class CreateRelatives < ActiveRecord::Migration[5.1]
  def change
    create_table :relatives do |t|
      t.references :client, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :relation

      t.timestamps
    end
  end
end
