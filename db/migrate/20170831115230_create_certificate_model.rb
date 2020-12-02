class CreateCertificateModel < ActiveRecord::Migration[5.1]
  def change
    create_table :certificates do |t|
      t.integer :hours
      t.integer :minutes
      t.date :duration_start
      t.date :duration_end
      t.text :institution
      t.text :text_body
      t.string :function
      t.jsonb :volunteer_contact
      t.jsonb :assignment_kinds
      t.belongs_to :volunteer, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
