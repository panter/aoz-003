class UpdateJournalCategory < ActiveRecord::Migration[5.1]
  def change
    Journal.where(category: 'file').each do |journal|
      journal.update(category: 'feedback')
    end
  end
end
