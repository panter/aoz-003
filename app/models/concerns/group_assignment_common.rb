module GroupAssignmentCommon
  extend ActiveSupport::Concern

  included do
    include GroupAssignmentAndAssignmentCommon
    include ImportRelation

    belongs_to :group_offer
    belongs_to :volunteer
    has_many :reminder_mailing_volunteers, as: :reminder_mailable, dependent: :destroy
    has_one :group_offer_category, through: :group_offer

    has_many :hours, ->(object) { where(volunteer: object.volunteer) }, through: :group_offer
    has_many :feedbacks, ->(object) { where(volunteer: object.volunteer) }, through: :group_offer
    has_one :department, through: :group_offer

    # termination record relations
    belongs_to :period_end_set_by, -> { with_deleted }, class_name: 'User', optional: true
    belongs_to :termination_submitted_by, -> { with_deleted }, class_name: 'User', optional: true
    belongs_to :termination_verified_by, -> { with_deleted }, class_name: 'User', optional: true

    scope :termination_submitted, (-> { where.not(termination_submitted_by_id: nil) })
    scope :termination_not_submitted, (-> { where(termination_submitted_by_id: nil) })
    scope :unterminated, (-> { where(termination_verified_by_id: nil) })
    scope :terminated, (-> { where.not(termination_verified_by_id: nil) })

    def to_label
      label_parts.compact.join(' - ')
    end

    def label_parts
      @label_parts ||= [
        'Gruppenangebot',
        group_offer.title,
        group_offer.department.present? && group_offer.department.contact.last_name
      ]
    end
  end
end
