class CreateReminderMailings < ActiveRecord::Migration[5.1]
  def change
    create_table :reminder_mailings do |t|
      t.references :creator, references: :users, index: true
      t.text :email_body
      t.string :subject
      t.integer :kind, default: 0

      t.timestamps
    end

  end
end
