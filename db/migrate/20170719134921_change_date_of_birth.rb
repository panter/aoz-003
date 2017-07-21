class ChangeDateOfBirth < ActiveRecord::Migration[5.1]
  def change
    rename_column :clients, :date_of_birth, :birth_year
    rename_column :relatives, :date_of_birth, :birth_year
    rename_column :volunteers, :date_of_birth, :birth_year
  end
end
