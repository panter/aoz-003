class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.integer     :kind, default: false
      t.date        :date
      t.time        :start_time
      t.time        :end_time
      t.string      :title
      t.text        :description

      t.belongs_to  :department, foreign_key: true
      t.references  :creator, references: :users, index: true
      t.datetime    :deleted_at, index: true
      t.timestamps
    end
  end
end

