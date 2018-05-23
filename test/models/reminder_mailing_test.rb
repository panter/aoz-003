require 'test_helper'

class ReminderMailingTest < ActiveSupport::TestCase
  def setup
    @superadmin = create :user
    @volunteer = create :volunteer
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

  test 'submission_count' do
    mailing = create :reminder_mailing, :half_year, reminder_mailing_volunteers:
      [@assignment_probation, @group_assignment_probation],
      created_at: 1.month.ago

    assert_equal 0, mailing.submission_count

    @assignment_probation.update(submitted_at: 2.months.ago)
    assert_equal 0, mailing.submission_count

    @assignment_probation.update(submitted_at: 1.day.ago)
    assert_equal 1, mailing.submission_count
  end
end
