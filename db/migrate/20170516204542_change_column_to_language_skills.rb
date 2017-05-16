class ChangeColumnToLanguageSkills < ActiveRecord::Migration[5.1]
  def change
    rename_column :language_skills, :client_id, :languageable_id
    add_column :language_skills, :languageable_type, :string
  end
end
