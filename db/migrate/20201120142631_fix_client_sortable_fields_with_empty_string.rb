class FixClientSortableFieldsWithEmptyString < ActiveRecord::Migration[6.0]
  def up
    Client.where(competent_authority: '').find_each do |client|
      client.update(competent_authority: nil)
    end
    Client.where(other_authorities: '').find_each do |client|
      client.update(competent_authority: nil)
    end
  end
end
