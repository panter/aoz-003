class RemoveDuplicateEmailAddresses < ActiveRecord::Migration[5.1]
  def up
    users = User
      .joins('JOIN users u USING (email)')
      .where('users.id != u.id')
      .where.not(email: [nil, ''])
      .order(id: :desc)
      .distinct

    users.find_each do |user|
      User
        .where(email: user.email)
        .where('id > ?', user.id)
        .destroy_all
    end

    contacts = Contact
      .joins('JOIN contacts c USING (primary_email)')
      .where('contacts.id != c.id')
      .where.not(primary_email: [nil, ''])
      .order(id: :desc)
      .distinct

    contacts.find_each do |contact|
      Contact
        .where(primary_email: contact.primary_email)
        .where('id > ?', contact.id)
        .destroy_all
    end
  end

  def down
  end
end
