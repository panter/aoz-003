class AddPdfColumns < ActiveRecord::Migration[5.1]
  def change
    add_attachment :assignments, :pdf
    add_attachment :group_assignments, :pdf
  end
end
