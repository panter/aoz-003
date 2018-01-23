module GroupAssignmentCommon
  extend ActiveSupport::Concern

  included do
    include GroupAssignmentAndAssignmentCommon
    include ImportRelation

    belongs_to :group_offer
    belongs_to :volunteer
    has_many :reminder_mailing_volunteers, as: :reminder_mailable, dependent: :destroy
    has_one :group_offer_category, through: :group_offer


    delegate :title, to: :group_offer

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
