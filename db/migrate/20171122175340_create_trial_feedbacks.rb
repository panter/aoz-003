class CreateTrialFeedbacks < ActiveRecord::Migration[5.1]
  def change
    create_table :trial_feedbacks do |t|
      t.text :body
      t.integer :trial_feedbackable_id
      t.string :trial_feedbackable_type
      t.belongs_to :volunteer
      t.references :author, index: true, foreign_key: { to_table: :users }
      t.references :reviewer, references: :users
      t.datetime :deleted_at, index: true
      t.timestamps
    end
    add_index :trial_feedbacks, [:trial_feedbackable_id, :trial_feedbackable_type], name: 'trial_feedback_polymorphic_index'
  end
end
