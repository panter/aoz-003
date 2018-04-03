require 'test_helper'

class ReminderMailingTest < ActiveSupport::TestCase
  def setup
    @superadmin = create :user
    @volunteer = create :volunteer_with_user
    @assignment_probation = create :assignment, period_start: 7.weeks.ago, volunteer: @volunteer
    @group_offer = create :group_offer
    @group_assignment_probation = GroupAssignment.create(volunteer: @volunteer,
      group_offer: @group_offer, period_start: 6.weeks.ago.to_date + 2)
  end

  test 'reminder_mailing_has_right_relations' do
    reminder_mailing = ReminderMailing.new(kind: :trial_period, body: 'aaa',
      subject: 'aaa', creator: @superadmin, reminder_mailing_volunteers: [
        @assignment_probation, @group_assignment_probation
      ])
    # pretend to set form select value
    reminder_mailing.reminder_mailing_volunteers.each do |rmv|
      rmv.picked = true
    end
    reminder_mailing.save
    assert reminder_mailing.users.include? @volunteer.user
    assert reminder_mailing.volunteers.include? @volunteer
    assert reminder_mailing.assignments.include? @assignment_probation
    assert reminder_mailing.group_assignments.include? @group_assignment_probation
  end

  test 'with_no_reminder_mailing_volunteer_picked_it_is_invalid' do
    reminder_mailing = ReminderMailing.new(kind: :trial_period, body: 'aaa',
      subject: 'aaa', creator: @superadmin, reminder_mailing_volunteers: [
        @assignment_probation, @group_assignment_probation
      ])

    refute reminder_mailing.valid?
    assert reminder_mailing.errors.messages[:volunteers].include?('Es muss mindestens '\
      'ein/e Freiwillige/r ausgewählt sein.')
  end

  test 'with_no_reminder_mailing_with_one_volunteer_picked_is_valid' do
    reminder_mailing = ReminderMailing.new(kind: :trial_period, body: 'aaa',
      subject: 'aaa', creator: @superadmin, reminder_mailing_volunteers: [
        @assignment_probation, @group_assignment_probation
      ])

    # pretend form sent with none checked
    reminder_mailing.reminder_mailing_volunteers.first.picked = false
    reminder_mailing.reminder_mailing_volunteers.first.picked = true

    assert reminder_mailing.valid?
  end

  test 'reminder_mailing_needs_to_have_subject_and_body' do
    reminder_mailing = ReminderMailing.new(kind: :trial_period, body: nil,
      subject: nil, creator: @superadmin, reminder_mailing_volunteers: [
        @assignment_probation, @group_assignment_probation
      ])
    reminder_mailing.reminder_mailing_volunteers.each do |rmv|
      rmv.picked = true
    end

    refute reminder_mailing.valid?
    assert_equal ['darf nicht leer sein'], reminder_mailing.errors[:subject]
    assert_equal ['darf nicht leer sein'], reminder_mailing.errors[:body]
    reminder_mailing.assign_attributes({
      subject: 'Erinnerung fuer %{Einsatz}',
      body: 'Hallo %{Anrede} %{Name}\r\n\r\n\r\n\r\n%{Einsatz} gestarted am %{EinsatzStart}'
    })
    assert reminder_mailing.valid?
  end

  test 'reminder_mailing_with_deleted_user_will_not_crash_views' do
    mailing_creator = create :user
    group_assignment = create(:group_assignment, group_offer: create(:group_offer),
      period_start: 2.months.ago, period_end: Time.zone.today, period_end_set_by: mailing_creator)
    reminder_mailing = create :reminder_mailing, kind: :termination, creator: mailing_creator,
      reminder_mailing_volunteers: [group_assignment], body: '%{EmailAbsender}'
    mailing_volunteer = reminder_mailing.reminder_mailing_volunteers.first
    mailing_body = mailing_volunteer.process_template[:body]
    assert(mailing_body.include?(mailing_creator.email),
      "#{mailing_creator.email} not found in #{mailing_body}")
    assert(mailing_body.include?(mailing_creator.profile.contact.natural_name),
      "#{mailing_creator.profile.contact.natural_name} not found in #{mailing_body}")
    mailing_creator.destroy
    reminder_mailing.reload
    mailing_volunteer.reload
    group_assignment.reload
    assert reminder_mailing.creator.deleted?, 'mailing creator should be deleted?'
    assert reminder_mailing.creator.profile.deleted?, 'creator profile should be deleted?'
    assert reminder_mailing.creator.profile.contact.deleted?, 'creator contact should be deleted?'
    mailing_body = mailing_volunteer.process_template[:body]
    assert(mailing_body.include?(mailing_creator.email),
      "#{mailing_creator.email} not found in #{mailing_body}")
    assert(mailing_body.include?(mailing_creator.profile.contact.natural_name),
      "#{mailing_creator.profile.contact.natural_name} not found in #{mailing_body}")
  end

  test 'feedback_helpers' do # rubocop:disable Metrics/BlockLength
    other_volunteer = create :volunteer_with_user
    other_group_assignment = create :group_assignment, group_offer: @group_offer,
      volunteer: other_volunteer
    _unrelated_feedback = create :feedback
    _unrelated_trial_feedback = create :trial_feedback

    half_year_mailing = create :reminder_mailing, :half_year, reminder_mailing_volunteers:
      [@assignment_probation, @group_assignment_probation, other_group_assignment],
      created_at: 1.month.ago

    trial_period_mailing = create :reminder_mailing, :trial_period, reminder_mailing_volunteers:
      [@assignment_probation, @group_assignment_probation, other_group_assignment],
      created_at: 1.month.ago

    assert_empty half_year_mailing.feedbacks
    assert_empty trial_period_mailing.feedbacks

    feedback1 = create :feedback, feedbackable: @assignment_probation,
      created_at: 1.day.ago, volunteer: @volunteer, author: @volunteer.user
    feedback2 = create :feedback, feedbackable: @assignment_probation,
      created_at: 2.days.ago, volunteer: @volunteer, author: @volunteer.user
    feedback3 = create :feedback, feedbackable: @group_offer,
      created_at: 3.days.ago, volunteer: @volunteer, author: @volunteer.user
    feedback4 = create :feedback, feedbackable: @group_offer,
      created_at: 4.days.ago, volunteer: other_volunteer, author: other_volunteer.user
    _feedback_past = create :feedback, feedbackable: @assignment_probation,
      created_at: 1.year.ago, volunteer: @volunteer, author: @volunteer.user
    _feedback_other_assignment = create :feedback, feedbackable: create(:assignment),
      created_at: 1.week.ago, volunteer: @volunteer, author: @volunteer.user
    _feedback_other_author = create :feedback, feedbackable: @assignment_probation,
      created_at: 1.week.ago, volunteer: @volunteer, author: @superadmin

    assert_equal [feedback1, feedback2, feedback3, feedback4],
      half_year_mailing.feedbacks.created_desc
    assert_equal 2, half_year_mailing.feedback_count

    trial_feedback1 = create :trial_feedback,
      trial_feedbackable: @assignment_probation,
      created_at: 1.day.ago, volunteer: @volunteer, author: @volunteer.user
    trial_feedback2 = create :trial_feedback,
      trial_feedbackable: @assignment_probation,
      created_at: 2.days.ago, volunteer: @volunteer, author: @volunteer.user
    trial_feedback3 = create :trial_feedback,
      trial_feedbackable: @group_offer,
      created_at: 3.days.ago, volunteer: @volunteer, author: @volunteer.user
    trial_feedback4 = create :trial_feedback,
      trial_feedbackable: @group_offer,
      created_at: 4.days.ago, volunteer: other_volunteer, author: other_volunteer.user
    _trial_feedback_past = create :trial_feedback,
      trial_feedbackable: @assignment_probation,
      created_at: 1.year.ago, volunteer: @volunteer, author: @volunteer.user
    _trial_feedback_other_assignment = create :trial_feedback,
      trial_feedbackable: create(:assignment),
      created_at: 1.week.ago, volunteer: @volunteer, author: @volunteer.user
    _trial_feedback_other_author = create :trial_feedback,
      trial_feedbackable: @assignment_probation,
      created_at: 1.week.ago, volunteer: @volunteer, author: @superadmin

    assert_equal [trial_feedback1, trial_feedback2, trial_feedback3, trial_feedback4],
      trial_period_mailing.feedbacks.created_desc
    assert_equal 2, trial_period_mailing.feedback_count
  end
end
