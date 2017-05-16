class CreateLanguageSkills < ActiveRecord::Migration[5.1]
  def change
    create_table :language_skills do |t|
      t.references :client
      t.string :language
      t.string :level

      t.timestamps
    end
  end
end
