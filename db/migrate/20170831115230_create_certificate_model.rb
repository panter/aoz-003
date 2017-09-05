class CreateCertificateModel < ActiveRecord::Migration[5.1]
  def change
    create_table :certificates do |t|
      t.jsonb :values

      t.references :volunteer, foreign_key: true
      t.references :user, foreign_key: true

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
