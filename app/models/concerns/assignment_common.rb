module AssignmentCommon
  extend ActiveSupport::Concern

  included do
    include ImportRelation
    include GroupAssignmentAndAssignmentCommon

    belongs_to :client
    accepts_nested_attributes_for :client

    belongs_to :creator, -> { with_deleted }, class_name: 'User'

    # termination record relations
    belongs_to :period_end_set_by, -> { with_deleted }, class_name: 'User', optional: true
    belongs_to :termination_submitted_by, -> { with_deleted }, class_name: 'User', optional: true
    belongs_to :termination_verified_by, -> { with_deleted }, class_name: 'User', optional: true


    scope :zurich, (-> { joins(:client).merge(Client.zurich) })
    scope :not_zurich, (-> { joins(:client).merge(Client.not_zurich) })

    scope :termination_submitted, (-> { where.not(termination_submitted_by_id: nil) })
    scope :termination_not_submitted, (-> { where(termination_submitted_by_id: nil) })
    scope :unterminated, (-> { where(termination_verified_by_id: nil) })
    scope :terminated, (-> { where.not(termination_verified_by_id: nil) })

    def creator
      super || User.deleted.find_by(id: creator_id)
    end

    def to_label
      label_parts.compact.join(' - ')
    end

    def label_parts
      @label_parts ||= [
        I18n.t('activerecord.models.assignment'),
        client.contact.full_name,
        period_start && I18n.l(period_start)
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
