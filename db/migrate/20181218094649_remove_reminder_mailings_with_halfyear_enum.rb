class RemoveReminderMailingsWithHalfyearEnum < ActiveRecord::Migration[5.1]
  def up
    ReminderMailing.where(kind: :half_year).destroy_all
    EmailTemplate.where(kind: :half_year).destroy_all
  end
end
