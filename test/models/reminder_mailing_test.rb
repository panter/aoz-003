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
    reminder_mailing = ReminderMailing.new(kind: :probation_period, body: 'aaa',
      subject: 'aaa', creator: @superadmin, reminder_mailing_volunteers: [
        @assignment_probation, @group_assignment_probation
      ])
    # pretend to set form select value
    reminder_mailing.reminder_mailing_volunteers.each do |rmv|
      rmv.selected = '1'
    end
    reminder_mailing.save
    assert reminder_mailing.users.include? @volunteer.user
    assert reminder_mailing.volunteers.include? @volunteer
    assert reminder_mailing.assignments.include? @assignment_probation
    assert reminder_mailing.group_assignments.include? @group_assignment_probation
  end

  test 'with_no_reminder_mailing_volunteer_selected_it_is_invalid' do
    reminder_mailing = ReminderMailing.new(kind: :probation_period, body: 'aaa',
      subject: 'aaa', creator: @superadmin, reminder_mailing_volunteers: [
        @assignment_probation, @group_assignment_probation
      ])

    # pretend form sent with none checked
    reminder_mailing.reminder_mailing_volunteers.each do |rmv|
      rmv.selected = '0'
    end

    refute reminder_mailing.valid?
    assert reminder_mailing.errors.messages[:volunteers].include?('Es muss mindestens '\
      'ein/e Freiwillige/r ausgewählt sein.')
  end

  test 'with_no_reminder_mailing_with_one_volunteer_selected_is_valid' do
    reminder_mailing = ReminderMailing.new(kind: :probation_period, body: 'aaa',
      subject: 'aaa', creator: @superadmin, reminder_mailing_volunteers: [
        @assignment_probation, @group_assignment_probation
      ])

    # pretend form sent with none checked
    reminder_mailing.reminder_mailing_volunteers.first.selected = '0'
    reminder_mailing.reminder_mailing_volunteers.first.selected = '1'

    assert reminder_mailing.valid?
  end

  test 'reminder_mailing_needs_to_have_subject_and_body' do
    reminder_mailing = ReminderMailing.new(kind: :probation_period, body: nil,
      subject: nil, creator: @superadmin, reminder_mailing_volunteers: [
        @assignment_probation, @group_assignment_probation
      ])
    # pretend to set form select value
    reminder_mailing.reminder_mailing_volunteers.each do |rmv|
      rmv.selected = '1'
    end

    refute reminder_mailing.valid?
    assert reminder_mailing.errors.messages[:subject].include? "can't be blank"
    assert reminder_mailing.errors.messages[:body].include? "can't be blank"
    reminder_mailing.assign_attributes({
      subject: 'Erinnerung fuer %{Einsatz}',
      body: 'Hallo %{Anrede} %{Name}\r\n\r\n\r\n\r\n%{Einsatz} gestarted am %{EinsatzStart}'
    })
    assert reminder_mailing.valid?
  end
end
