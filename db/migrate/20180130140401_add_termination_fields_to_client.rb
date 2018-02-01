class AddTerminationFieldsToClient < ActiveRecord::Migration[5.1]
  def change
    change_table :clients do |t|
      t.date :resigned_on
      t.references :resigned_by, references: :users, index: true
    end
  end
end
