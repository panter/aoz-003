class RemoveMailingLinkVisitsField < ActiveRecord::Migration[5.1]
  def change
    change_table :reminder_mailing_volunteers do |t|
      t.remove :link_visits
    end
  end
end
