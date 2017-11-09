class UpdateContactFullNameOnExistingContacts < ActiveRecord::Migration[5.1]
  def up
    Contact
      .where.not(contactable_type: 'Department')
      .where(full_name: nil)
      .map do |contact|
        contact.update_full_name
        contact.save
      end
  end
end
