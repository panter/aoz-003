class AddFieldsToGroupAssignment < ActiveRecord::Migration[5.1]
  def change
    add_column :group_assignments, :place, :string
    add_column :group_assignments, :description, :text
    add_column :group_assignments, :happens_at, :string
    add_column :group_assignments, :frequency, :string
    add_column :group_assignments, :trial_period_end, :string
    add_column :group_assignments, :agreement_text, :text, default: <<~HEREDOC
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
