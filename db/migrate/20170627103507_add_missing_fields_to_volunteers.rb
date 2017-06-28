class AddMissingFieldsToVolunteers < ActiveRecord::Migration[5.1]
  def change
    change_table :volunteers do |t|
      t.string :working_percent
      t.text :volunteer_experience_desc
      t.string :region_specific
      t.remove :skills
    end

    change_table :contacts do |t|
      t.string :title
    end
  end
end
