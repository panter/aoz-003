class CreateSemesterFeedbacks < ActiveRecord::Migration[5.1]
  def change
    create_table :semester_feedbacks do |t|
      t.references :author, references: :users, index: true
      t.references :semester_process_volunteer, index: false
      # for relations to either Assignment or GroupAssignment (not GroupOffer!)
      t.integer :semester_feedbackable_id
      t.string :semester_feedbackable_type
      t.text :goals
      t.text :achievements
      t.text :future
      t.text :comments
      t.boolean :conversation, default: false

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
