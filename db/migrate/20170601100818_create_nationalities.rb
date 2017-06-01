class CreateNationalities < ActiveRecord::Migration[5.1]
  def change
    create_table :nationalities do |t|
      t.string :nation
      t.references :people
      t.timestamps
      t.datetime :deleted_at
    end

    add_index :nationalities, :deleted_at
  end
end
