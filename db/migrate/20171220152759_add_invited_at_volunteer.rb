class AddInvitedAtVolunteer < ActiveRecord::Migration[5.1]
  def change
    change_table :volunteers do |t|
      t.datetime :invited_at
    end
  end
end
