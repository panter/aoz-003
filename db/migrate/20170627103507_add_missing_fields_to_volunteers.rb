class AddMissingFieldsToVolunteers < ActiveRecord::Migration[5.1]
  def change
    change_table :volunteers do |t|
      t.string :working_percent
      t.text :volunteer_experience_desc
      t.string :region_specific
    end
  end
end
