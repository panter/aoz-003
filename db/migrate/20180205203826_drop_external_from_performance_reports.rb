class DropExternalFromPerformanceReports < ActiveRecord::Migration[5.1]
  def change
    change_table :performance_reports do |t|
      t.remove :extern
      t.remove :scope
    end
  end
end
