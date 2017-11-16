class CreateEmailTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :email_templates do |t|
      t.string :subject
      t.text :body
      t.integer :kind
      t.boolean :active
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
