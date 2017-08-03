class CreateAccessImports < ActiveRecord::Migration[5.1]
  def change
    create_table :imports do |t|
      t.bigint :access_id, index: true
      t.jsonb :store
      t.references :importable, polymorphic: true, index: true
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
