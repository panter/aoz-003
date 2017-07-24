class AddImportCollumns < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :import_store, :jsonb
    add_column :volunteers, :import_store, :jsonb

  end
end
