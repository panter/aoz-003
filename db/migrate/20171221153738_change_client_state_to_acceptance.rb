class ChangeClientStateToAcceptance < ActiveRecord::Migration[5.1]
  def up
    add_column :clients, :acceptance, :integer, default: 0
    Client.find_each do |client|
      if ['registered', 'reserved', 'active'].include?(client.state)
        client.update(acceptance: 'accepted')
      elsif client.state == 'finished'
        client.update(acceptance: 'resigned')
      else
        client.update(acceptance: 'rejected')
      end
    end
    remove_column :clients, :state
  end

  def down
    add_column :clients, :state, :string, default: 'registered'
    Client.find_each do |client|
      if client.acceptance == 'accepted'
        client.update(state: 'registered')
      elsif client.acceptance == 'resigned'
        client.update(state: 'finished')
      else
        client.update(state: 'rejected')
      end
    end
    remove_column :clients, :acceptance
  end
end
