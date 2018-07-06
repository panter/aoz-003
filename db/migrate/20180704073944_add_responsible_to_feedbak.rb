class AddResponsibleToFeedbak < ActiveRecord::Migration[5.1]
  def change
    change_table :feedbacks do |t|
      t.references :responsible, references: :users
      t.datetime :responsible_at
    end
  end
end
