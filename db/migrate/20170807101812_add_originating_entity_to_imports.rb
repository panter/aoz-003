class AddOriginatingEntityToImports < ActiveRecord::Migration[5.1]
  def change
    add_column :imports, :base_origin_entity, :string
  end
end
