# This migration comes from has_vcards (originally 20120119091225)
class AddIndexToVcards < ActiveRecord::Migration[5.1]
  def change
    add_index :vcards, :active
  end
end
