class AddPrimaryEmailToContact < ActiveRecord::Migration[5.1]
  def change
    change_table :contacts do |t|
      t.string :primary_email
      t.string :primary_phone
    end
  end
end
