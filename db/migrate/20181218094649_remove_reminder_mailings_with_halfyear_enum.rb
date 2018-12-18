class RemoveReminderMailingsWithHalfyearEnum < ActiveRecord::Migration[5.1]
  def up
    ReminderMailing.where(kind: 0).destroy_all
    EmailTemplate.where(kind: 3).destroy_all
  end
end
