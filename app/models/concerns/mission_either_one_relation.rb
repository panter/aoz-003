module MissionEitherOneRelation
  extend ActiveSupport::Concern

  included do
    # relates to either Assignment or GroupAssignment (not GroupOffer!)
    belongs_to :assignment, optional: true
    belongs_to :group_assignment, optional: true

    validate :validate_group_assignment_or_assignment_present

    attr_accessor :mission_id

    def mission=(mission)
      if mission.class.name == 'Assignment'
        self.assignment = mission
      else
        self.group_assignment = mission
      end
    end

    def mission
      group_assignment || assignment
    end

    private

    def validate_group_assignment_or_assignment_present
      if assignment.blank? && group_assignment.blank?
        errors.add(:assignment, :insuficient_relation)
        errors.add(:group_assignment, :insuficient_relation)
      elsif assignment.present? && group_assignment.present?
        errors.add(:assignment, :too_many_relations)
        errors.add(:group_assignment, :too_many_relations)
      end
    end
  end
end
