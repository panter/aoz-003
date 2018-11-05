module AssignmentCommon
  extend ActiveSupport::Concern

  included do
    include ImportRelation
    include GroupAssignmentAndAssignmentCommon

    belongs_to :client
    accepts_nested_attributes_for :client

    belongs_to :creator, -> { with_deleted }, class_name: 'User', inverse_of: 'assignments'

    # termination record relations
    belongs_to :period_end_set_by, -> { with_deleted }, class_name: 'User',
      inverse_of: 'assignment_period_ends_set', foreign_key: 'period_end_set_by_id', optional: true
    belongs_to :termination_submitted_by, -> { with_deleted }, class_name: 'User',
      inverse_of: 'assignment_terminations_submitted', optional: true
    belongs_to :termination_verified_by, -> { with_deleted }, class_name: 'User',
      inverse_of: 'assignment_terminations_verified', optional: true
    belongs_to :submitted_by, -> { with_deleted }, class_name: 'User',
      inverse_of: 'assignments_submitted', foreign_key: 'submitted_by_id', optional: true

    scope :zurich, (-> { joins(:client).merge(Client.zurich) })
    scope :not_zurich, (-> { joins(:client).merge(Client.not_zurich) })

    def creator
      super || User.deleted.find_by(id: creator_id)
    end

    def to_label
      label_parts.compact.join(' - ')
    end

    def label_parts
      @label_parts ||= [
        I18n.t('activerecord.models.assignment'),
        client.contact.full_name
      ]
    end
  end

  def assignment?
    true
  end

  def group_assignment?
    false
  end
end
