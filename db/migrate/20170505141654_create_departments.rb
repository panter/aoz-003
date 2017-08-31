class CreateDepartments < ActiveRecord::Migration[5.1]
  def change
    create_table :departments do |t|
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
