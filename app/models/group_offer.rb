class GroupOffer < ApplicationRecord
  include ImportRelation

  TARGET_GROUP = [:women, :men, :children, :teenagers, :unaccompanied, :all].freeze
  DURATION = [:long_term, :regular, :short_term].freeze
  OFFER_TYPES = [:internal_offer, :external_offer].freeze
  EXTERNAL_OFFER = 'external_offer'.freeze
  OFFER_STATES = [:open, :partially_occupied, :full].freeze
  VOLUNTEER_STATES = [:internal_volunteer, :external_volunteer].freeze

  belongs_to :department, optional: true
  belongs_to :group_offer_category
  belongs_to :creator, -> { with_deleted }, class_name: 'User', optional: true

  # termination record relations
  belongs_to :period_end_set_by, -> { with_deleted }, class_name: 'User', optional: true
  belongs_to :termination_verified_by, -> { with_deleted }, class_name: 'User', optional: true

  has_many :group_assignments, dependent: :destroy
  accepts_nested_attributes_for :group_assignments, allow_destroy: true

  has_many :group_assignment_logs
  has_many :volunteers, through: :group_assignments
  has_many :volunteer_logs, through: :group_assignment_logs

  has_many :hours, as: :hourable, dependent: :destroy
  has_many :feedbacks, as: :feedbackable, dependent: :destroy
  has_many :trial_feedbacks, as: :trial_feedbackable, dependent: :destroy

  has_many :volunteer_contacts, through: :volunteers, source: :contact

  validates :title, presence: true
  validates :necessary_volunteers, numericality: { greater_than: 0 }, allow_nil: true

  scope :active, (-> { where(active: true) })
  scope :inactive, (-> { where(active: false) })

  scope :in_department, (-> { where.not(department_id: nil) })

  scope :active_group_assignments_between, lambda { |start_date, end_date|
    joins(:group_assignments).merge(GroupAssignment.active_between(start_date, end_date))
  }

  def active_group_assignments_between?(start_date, end_date)
    group_assignments.active_between(start_date, end_date).any?
  end

  def all_group_assignments_ended_within?(date_range)
    ended_within = group_assignments.end_within(date_range).ids
    not_end_before = group_assignments.end_after(date_range.last).ids
    not_end_before += group_assignments.no_end.ids if date_range.last >= Time.zone.today
    ended_within.any? && not_end_before.blank?
  end

  def all_group_assignments_started_within?(date_range)
    started_within = group_assignments.start_within(date_range)
    started_before = group_assignments.start_before(date_range.first)
    return true if started_within.size == group_assignments.size
    return true unless started_before.any?
    false
  end

  def assignment?
    false
  end

  def external?
    offer_type == EXTERNAL_OFFER
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
    end.compact.join(', ')
  end

  def update_search_volunteers
    update(search_volunteer: volunteer_contacts.pluck(:full_name).join(', '))
  end
end
