class AddMarkedDoneByFields < ActiveRecord::Migration[5.1]
  def change
    change_table :hours do |t|
      t.belongs_to :marked_done_by, references: :user, optional: true
    end

    change_table :feedbacks do |t|
      t.belongs_to :marked_done_by, references: :user, optional: true
    end

    change_table :trial_feedbacks do |t|
      t.belongs_to :marked_done_by, references: :user, optional: true
    end
  end
end
