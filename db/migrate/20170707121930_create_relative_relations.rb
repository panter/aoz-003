class CreateRelativeRelations < ActiveRecord::Migration[5.1]
  def change
    create_table :relative_relations do |t|
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end

    relative_values = ['wife', 'husband', 'mother', 'father', 'daughter',
    'son', 'sister', 'brother', 'aunt', 'uncle']

    reversible do |dir|
      dir.up do
        relative_values.each do |item|
          execute "insert into relative_relations(name, created_at, updated_at) values('#{item}', '#{DateTime.now.utc.to_formatted_s}', '#{DateTime.now.utc.to_formatted_s}')"
        end
      end
      dir.down do
      end
    end

    change_table :relatives do |t|
      t.references :relative_relations, foreign_key: true
    end
  end
end
