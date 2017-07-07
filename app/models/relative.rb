class Relative < ApplicationRecord
  include FullName
  include YearCollection

  belongs_to :relativeable, polymorphic: true, optional: true

  belongs_to :relative_relations, polymorphic: true, optional: true

  def to_s
    relation_human = relation ? I18n.t(relation, scope: [:relation]) : ''
    [full_name, date_of_birth.try(:year), relation_human].reject(&:blank?).join(', ')
  end
end
