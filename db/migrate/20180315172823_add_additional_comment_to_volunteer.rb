class AddAdditionalCommentToVolunteer < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :comments, :text
    add_column :volunteers, :additional_comments, :text

    add_column :clients, :additional_comments, :text

    add_column :assignments, :comments, :text
    add_column :assignments, :additional_comments, :text
    add_column :assignment_logs, :comments, :text
    add_column :assignment_logs, :additional_comments, :text

    add_column :group_assignments, :comments, :text
    add_column :group_assignments, :additional_comments, :text
    add_column :group_assignment_logs, :comments, :text
    add_column :group_assignment_logs, :additional_comments, :text

    reversible do |dir|
      dir.up do
        change_column :hours, :comments, :text
        change_column :feedbacks, :comments, :text
      end

      dir.down do
        change_column :hours, :comments, :string
        change_column :feedbacks, :comments, :string
      end
    end
  end
end
