class RemoveOldFeedbacks < ActiveRecord::Migration[5.1]
  def change
    drop_table :feedbacks
  end
end
