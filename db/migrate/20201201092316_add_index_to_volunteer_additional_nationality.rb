class AddIndexToVolunteerAdditionalNationality < ActiveRecord::Migration[6.0]
  def change
    change_table :volunteers do |t|
      t.index :additional_nationality
    end
  end
end
