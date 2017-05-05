class CreateDepartementUserJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :users, :departements do |t|
      t.index [:departement_id, :user_id]
    end
  end
end
