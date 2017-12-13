class AddReviewerToFeedbackAndHours < ActiveRecord::Migration[5.1]
  def change
    change_table :hours do |t|
      t.belongs_to :reviewer, references: :user, optional: true
    end

    change_table :feedbacks do |t|
      t.belongs_to :reviewer, references: :user, optional: true
    end
  end
end
