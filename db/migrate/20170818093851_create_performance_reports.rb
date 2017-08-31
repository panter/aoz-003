class CreatePerformanceReports < ActiveRecord::Migration[5.1]
  def change
    create_table :performance_reports do |t|
      t.date :period_start
      t.date :period_end
      t.integer :year
      t.references :user, foreign_key: true
      t.jsonb :report_content
      t.boolean :extern, default: false
      t.string :scope
      t.string :title
      t.text :comment

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
