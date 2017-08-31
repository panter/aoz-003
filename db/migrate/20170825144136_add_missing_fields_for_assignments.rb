class AddMissingFieldsForAssignments < ActiveRecord::Migration[5.1]
  def change
    change_table :assignments do |t|
      t.datetime :progress_meeting        # Standortgespräch
      t.datetime :first_lesson            # ErstUnterricht
      t.datetime :home_visit              # Hausbesuch
      t.datetime :probation_period        # Probezeit
      t.boolean  :probation_period_report # Probezeitbericht
      t.string   :short_description       # Kurzbezeichnung
      t.text     :goals                   # Zielsetzung
      t.text     :starting_topic          # Einstiegsthematik
      t.text     :description             # Beschreibung
    end
  end
end
