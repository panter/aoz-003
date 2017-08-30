class CreateLanguageSkills < ActiveRecord::Migration[5.1]
  def change
    create_table :language_skills do |t|
      t.string :language
      t.string :level

      t.references :languageable, polymorphic: true, index: true

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
