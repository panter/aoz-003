class RemoveSubjectFromJournals < ActiveRecord::Migration[5.1]
  def change
    remove_column :journals, :subject, :string
  end
end
