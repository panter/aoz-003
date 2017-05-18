class RemoveForeignKeyFromLanguageSkills < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :language_skills, :clients
  end
end
