class AddImportStoreToTables < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :access_import, :jsonb
    add_column :volunteers, :access_import, :jsonb
    add_column :journals, :access_import, :jsonb
  end
end
