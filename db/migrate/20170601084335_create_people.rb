class CreatePeople < ActiveRecord::Migration[5.1]
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.string :title
      t.string :gender
      t.date :date_of_birth
      t.text :education
      t.text :hobbies
      t.text :interests
      t.string :profession
      t.references :personable, polymorphic: true, index: true
      t.timestamps
      t.datetime :deleted_at
      t.attachment :avatar
    end

    add_index :people, :deleted_at
  end
end
