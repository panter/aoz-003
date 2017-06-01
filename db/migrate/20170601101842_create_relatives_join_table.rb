class CreateRelativesJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :relatives, :people do |t|
      t.index [:person_id, :relative_id]
    end
  end
end
