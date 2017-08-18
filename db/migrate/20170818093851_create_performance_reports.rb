class CreatePerformanceReports < ActiveRecord::Migration[5.1]
  def change
    create_table :performance_reports do |t|
      t.date :period_start
      t.date :period_end
      t.references :user, foreign_key: true
      t.jsonb :report_content
      t.boolean :extern, default: false
      t.string :scope

      t.timestamps
    end

    add_column :performance_reports, :deleted_at, :datetime
    add_index :performance_reports, :deleted_at
  end
end
