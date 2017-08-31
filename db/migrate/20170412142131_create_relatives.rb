class CreateRelatives < ActiveRecord::Migration[5.1]
  def change
    create_table :relatives do |t|
      t.string :first_name
      t.string :last_name
      t.date :birth_year
      t.string :relation

      t.references :relativeable, polymorphic: true, index: true

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
