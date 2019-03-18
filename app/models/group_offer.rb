class GroupOffer < ApplicationRecord
  include ImportRelation
  include TerminationScopes

  TARGET_GROUP = [:women, :men, :children, :teenagers, :unaccompanied, :all].freeze
  DURATION = [:long_term, :regular, :short_term].freeze
  OFFER_TYPES = [:internal_offer, :external_offer].freeze
  OFFER_STATES = [:open, :partially_occupied, :full].freeze

  belongs_to :department, optional: true
  belongs_to :group_offer_category
  belongs_to :creator, -> { with_deleted }, class_name: 'User',
    inverse_of: 'group_offers'

  # termination record relations
  belongs_to :period_end_set_by, -> { with_deleted }, class_name: 'User', optional: true,
    inverse_of: 'group_offer_period_ends_set'

  has_many :group_assignments, dependent: :destroy
  accepts_nested_attributes_for :group_assignments, allow_destroy: true

  has_many :group_assignment_logs

  has_many :hours, as: :hourable, dependent: :destroy
  has_many :feedbacks, as: :feedbackable, dependent: :destroy
  has_many :trial_feedbacks, as: :trial_feedbackable, dependent: :destroy

  has_many :volunteers, through: :group_assignments
  has_many :volunteer_contacts, through: :volunteers, source: :contact

  validates :title, :offer_type, presence: true
  validates :necessary_volunteers, numericality: { greater_than: 0 }, allow_nil: true
  validates :period_end, absence: {
    message: lambda { |object, _|
               'Dieses Gruppenangebot kann noch nicht beendet werden, da es noch '\
                 "#{object.group_assignments.running.count} laufende Gruppeneinsätze hat."
             }
  }, if: :running_assignments?

  validates :department, presence: true, if: :internal?
  validates :organization, :location, presence: true, if: :external?
  validates :active, inclusion: { in: [false] }, if: :terminated?

  scope :active, (-> { where(active: true) })
  scope :inactive, (-> { where(active: false) })

  scope :internal, (-> { where(offer_type: 'internal_offer') })
  scope :external, (-> { where(offer_type: 'external_offer') })

  scope :active_group_assignments_between, lambda { |start_date, end_date|
    joins(:group_assignments).merge(GroupAssignment.active_between(start_date, end_date))
  }

  scope :ended_group_assignments_between, lambda { |start_date, end_date|
    joins(:group_assignments).merge(GroupAssignment.end_within(start_date, end_date))
  }

  scope :started_group_assignments_between, lambda { |start_date, end_date|
    joins(:group_assignments).merge(GroupAssignment.start_within(start_date, end_date))
  }

  scope :no_end, (-> { field_nil(:period_end) })
  scope :has_end, (-> { field_not_nil(:period_end) })
  scope :end_before, ->(date) { date_before(:period_end, date) }
  scope :end_at_or_before, ->(date) { date_at_or_before(:period_end, date) }
  scope :end_after, ->(date) { date_after(:period_end, date) }
  scope :end_at_or_after, ->(date) { date_at_or_after(:period_end, date) }

  scope :end_within, lambda { |start_date, end_date|
    date_between_inclusion(:period_end, start_date, end_date)
  }

  scope :terminated, (-> { field_not_nil(:period_end_set_by) })

  def terminatable?
    group_assignments.unterminated.none?
  end

  def terminated?
    period_end_set_by.present? && period_end.present?
  end

  def active_group_assignments_between?(start_date, end_date)
    group_assignments.active_between(start_date, end_date).any?
  end

  def all_group_assignments_ended_within?(start_date, end_date)
    ended_within = group_assignments.end_within(start_date, end_date).ids
    not_end_before = group_assignments.end_after(end_date).ids
    not_end_before += group_assignments.no_end.ids if end_date >= Time.zone.today
    ended_within.any? && not_end_before.blank?
  end

  def all_group_assignments_started_within?(start_date, end_date)
    started_within = group_assignments.start_within(start_date, end_date)
    started_before = group_assignments.start_before(start_date)
    return true if started_within.size == group_assignments.size
    return true unless started_before.any?
    false
  end

  def assignment?
    false
  end

  def internal?
    offer_type.to_s == 'internal_offer'
  end

  def external?
    offer_type.to_s == 'external_offer'
  end

  def responsible?(volunteer)
    group_assignments.find_by(volunteer: volunteer).responsible
  end

  def to_label
    label = "#{I18n.t('activerecord.models.group_offer')} - #{title} - #{group_offer_category}"
    label += " - #{department}" if department_id?
    label
  end

  def label_parts
    [
      I18n.t('activerecord.models.group_offer'),
      title,
      group_offer_category.to_s,
      department&.to_s
    ]
  end

  def full_location
    if external?
      "#{organization} #{location}"
    elsif department
      department.to_s
    else
      ''
    end
  end

  def volunteers_with_roles
    volunteers.map do |volunteer|
      if responsible?(volunteer)
        "#{volunteer} (#{I18n.t('activerecord.attributes.group_assignment.responsible')})"
      else
        "#{volunteer} (#{I18n.t('activerecord.attributes.group_assignment.member')})"
      end
    end.compact
  end

  def update_search_volunteers
    update(search_volunteer: volunteer_contacts.pluck(:full_name).join(', '))
  end

  private

  def running_assignments?
    group_assignments.running.any?
  end
end
