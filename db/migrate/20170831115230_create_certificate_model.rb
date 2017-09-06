class CreateCertificateModel < ActiveRecord::Migration[5.1]
  def change
    create_table :certificates do |t|
      t.integer :hours
      t.integer :minutes
      t.date :duration_start
      t.date :duration_end
      t.text :institution
      t.jsonb :paragraphs
      t.jsonb :assignment_kinds
      t.references :volunteer, foreign_key: true
      t.references :user, foreign_key: true
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
