class AddAdditionalCommentToVolunteer < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :comments, :text
    add_column :volunteers, :additional_comments, :text
  end
end
