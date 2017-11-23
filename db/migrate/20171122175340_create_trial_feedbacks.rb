class CreateTrialFeedbacks < ActiveRecord::Migration[5.1]
  def change
    create_table :trial_feedbacks do |t|
      t.text :body
      t.integer :feedbackable_id
      t.string :feedbackable_type
      t.index [:feedbackable_id, :feedbackable_type]
      t.belongs_to :volunteer
      t.references :author, references: :users
      t.references :reviewer, references: :users
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
