class CreateCertificateModel < ActiveRecord::Migration[5.1]
  def change
    create_table :certificates do |t|
      t.string :institution
      t.string :function
      t.string :mission
      t.string :period
      t.string :duration
      t.string :creator_details

      t.text :description

      t.references :volunteer, foreign_key: true
      t.references :user, foreign_key: true

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
