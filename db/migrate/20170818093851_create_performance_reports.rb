class CreatePerformanceReports < ActiveRecord::Migration[5.1]
  def change
    create_table :performance_reports do |t|
      t.datetime :period_start
      t.datetime :period_end
      t.references :user, foreign_key: true
      t.jsonb :report_content
      t.boolean :extern, default: false
      t.string :scope
      t.string :title
      t.text :comment

      t.timestamps
    end

    add_column :performance_reports, :deleted_at, :datetime
    add_index :performance_reports, :deleted_at
  end
end
