class AddSpeakerToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :speaker, :string
  end
end
