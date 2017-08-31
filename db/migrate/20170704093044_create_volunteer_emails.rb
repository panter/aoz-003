class CreateVolunteerEmails < ActiveRecord::Migration[5.1]
  def change
    create_table :volunteer_emails do |t|
      t.string :subject
      t.string :title
      t.text :body
      t.references :user, foreign_key: true
      t.boolean :active, default: false

      t.datetime :deleted_at
      t.timestamps
    end
    add_index :volunteer_emails, :deleted_at
  end
end
