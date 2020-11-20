class TrialPeriod < ApplicationRecord
  belongs_to :verified_by, class_name: 'User',
                           foreign_key: 'verified_by_id',
                           inverse_of: :verified_trial_periods,
                           optional: true

  belongs_to :trial_period_mission, polymorphic: true, inverse_of: :trial_period
  alias_attribute :mission, :trial_period_mission

  scope :not_verified, lambda {
    where(verified_at: nil).where.not(end_date: nil)
  }

  scope :verified, -> { where.not(verified_at: nil) }

  scope :trial_period_running, lambda {
    not_verified.where('end_date >= ?', Date.current)
  }

  scope :trial_period_overdue, lambda {
    not_verified.where('end_date < ?', Date.current)
  }

  def verified?
    end_date.present? && verified_at.present?
  end

  def unverified?
    end_date.present? && verified_at.blank?
  end

  def overdue?
    unverified? && end_date < Date.current
  end

  def verify!(verifier)
    journal = journal_for_verify(verifier)
    journal.assignment = mission if mission.class.name == 'Assignment'
    journal.save!
    update!(verified_at: Time.zone.now, verified_by: verifier, notes: nil)
  end

  # allow ransack to use defined scopes
  def self.ransackable_scopes(_auth_object = nil)
    ['not_verified', 'verified', 'trial_period_running', 'trial_period_overdue']
  end

  private

  def journal_for_verify(verifier)
    Journal.new(user: verifier,
                journalable: mission.volunteer,
                category: :feedback,
                title: "Probezeit Quittiert von #{verifier.profile.full_name} <#{verifier.email}>",
                body: "Einsatz: #{mission.to_label}")
  end
end
