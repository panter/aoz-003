class AddHearFromWhereQuetionFieldsToVolunteer < ActiveRecord::Migration[5.1]
  def change
    change_table :volunteers do |t|
      t.string :how_have_you_heard_of_aoz
      t.text :how_have_you_heard_of_aoz_other
    end
  end
end
