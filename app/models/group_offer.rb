class GroupOffer < ApplicationRecord
  TARGET_GROUP = [:women, :men, :children, :teenagers, :unaccompanied, :all].freeze
  DURATION = [:long_term, :regular, :short_term].freeze
  OFFER_TYPES = [:internal_offer, :external_offer].freeze
  EXTERNAL_OFFER = 'external_offer'.freeze
  OFFER_STATES = [:open, :partially_occupied, :full].freeze
  VOLUNTEER_STATES = [:internal_volunteer, :external_volunteer].freeze

  belongs_to :department, optional: true
  belongs_to :group_offer_category

  has_many :group_assignments, dependent: :destroy
  has_many :volunteers, through: :group_assignments
  has_many :hours, as: :hourable, dependent: :destroy

  accepts_nested_attributes_for :group_assignments, allow_destroy: true

  validates :title, presence: true
  has_many :feedbacks, as: :feedbackable, dependent: :destroy

  validates :necessary_volunteers, numericality: { greater_than: 0 }, allow_nil: true

  scope :active, (-> { where(active: true) })
  scope :archived, (-> { where(active: false) })

  scope :in_department, (-> { where.not(department_id: nil) })

  scope :active_group_assignments_between, lambda { |start_date, end_date|
    joins(:group_assignments).merge(GroupAssignment.active_between(start_date, end_date))
  }

  scope :created_before, ->(date) { where('created_at < ?', date) }

  def external?
    offer_type == EXTERNAL_OFFER
  end

  def archived
    archived
  end

  def responsible?(volunteer)
    group_assignments.find_by(volunteer: volunteer).responsible
  end

  def to_label
    label = "#{self.class.name.humanize} - #{title} - #{group_offer_category}"
    label += " - #{department}" if department_id?
    label
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
end
