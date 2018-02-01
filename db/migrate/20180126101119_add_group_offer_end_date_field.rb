class AddGroupOfferEndDateField < ActiveRecord::Migration[5.1]
  def change
    change_table :group_offers do |t|
      t.references :period_end_set_by, references: :users, index: true
      t.references :termination_verified_by, references: :users, index: true
      t.date :period_start
      t.date :period_end
      t.datetime :termination_verified_at
    end
  end
end
