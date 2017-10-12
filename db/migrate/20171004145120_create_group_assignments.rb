class CreateGroupAssignments < ActiveRecord::Migration[5.1]
  def change
    drop_table :group_offers_volunteers
    create_table :group_assignments do |t|
      t.belongs_to :group_offer, index: true
      t.belongs_to :volunteer, index: true
      t.date :period_start
      t.date :period_end
      t.boolean :responsible, default: false
      t.datetime :deleted_at, index: true
    end
  end
end
