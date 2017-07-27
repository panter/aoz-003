class AddDocSentToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :doc_sent, :boolean, default: false
  end
end
