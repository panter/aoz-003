class AddFirstNameLastNameToContacts < ActiveRecord::Migration[5.1]
  def change
    add_column :contacts, :first_name, :string
    add_column :contacts, :last_name, :string

    Contact.where.not(name: nil).each do |contact|
      contact.last_name = contact.last_name
      contact.save
    end

    remove_column :contacts, :name, :string
  end
end
