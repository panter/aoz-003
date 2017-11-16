class CreateClientNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :client_notifications do |t|
      t.text :body
      t.references :user, foreign_key: true
      t.boolean :active
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :client_notifications, :deleted_at
  end
end
