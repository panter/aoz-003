class AddOtherAuthoritiesToClients < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :other_authorities, :text
  end
end
