class AddCreatorToCertificates < ActiveRecord::Migration[5.1]
  def change
    add_column :certificates, :creator_name,     :string
    add_column :certificates, :creator_function, :string
  end
end
