class AddFieldsToAssignment < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :assignment_description, :string
    add_column :assignments, :first_meeting, :string
    add_column :assignments, :frequency, :string
    add_column :assignments, :trial_period_end, :string
    add_column :assignments, :duration, :string
    add_column :assignments, :special_agreement, :string
    add_column :assignments, :agreement_text, :text, default: <<~HEREDOC
      Freiwillige beachten folgende Grundsätze während ihres Einsatzes in der AOZ:
      * Verhaltenskodex für Freiwillige
      * Rechte und Pflichten für Freiwillige
      * AOZ Leitlinien Praktische Integrationsarbeit

      Allenfalls auch
      * Verpflichtungserklärung zum Schutz der unbegleiteten minderjährigen Asylsuchenden (MNA)
      * Niederschwellige Gratis-Deutschkurse: Informationen für freiwillige Kursleitende
    HEREDOC
  end
end
