class CreateRelatives < ActiveRecord::Migration[5.1]
  def change
    create_table :relatives do |t|
      t.belongs_to :client, foreign_key: true
      t.string :firstname
      t.string :lastname
      t.date :dob
      t.string :relation

      t.timestamps
    end
  end
end
