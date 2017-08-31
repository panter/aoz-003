class AddMissingFieldsForAssignments < ActiveRecord::Migration[5.1]
  def change
    change_table :assignments do |t|
      t.datetime :progress_meeting             # Standortgespräch
      t.string   :short_description            # Kurzbezeichnung
      t.text     :goals                        # Zielsetzung
      t.text     :starting_topic               # Einstiegsthematik
      t.text     :description                  # Beschreibung
    end
  end
end
