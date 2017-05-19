class RemoveIndexAddIndexToLanguageSkills < ActiveRecord::Migration[5.1]
  def change
    remove_index :language_skills, :languageable_id
    add_index :language_skills, [:languageable_type, :languageable_id]
  end
end
