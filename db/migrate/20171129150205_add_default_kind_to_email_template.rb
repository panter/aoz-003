class AddDefaultKindToEmailTemplate < ActiveRecord::Migration[5.1]
  def change
    change_column :email_templates, :kind, :integer, default: 0
  end
end
