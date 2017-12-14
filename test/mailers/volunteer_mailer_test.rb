require 'test_helper'

class VolunteerMailerTest < ActionMailer::TestCase
  def setup
    @volunteer = create :volunteer, education: 'Bogus Education', woman: true
    @email_template = create :email_template
  end

  test 'volunteer welcome mail with confirmation data is sent correctly' do
    # FIXME: Problem with umlauts, but only in tests. Test doesn't recognize
    # email encoded utf-8 umlauts
    @volunteer.contact.city = 'Zuerich'
    @volunteer.save
    mailer = VolunteerMailer.welcome_email(@volunteer, @email_template).deliver
    assert_equal @email_template.subject, mailer.subject
    assert_equal [@volunteer.contact.primary_email], mailer.to
    assert_equal ['info@aoz-freiwillige.ch'], mailer.from

    mail_body = mailer.body.encoded
    assert_match @volunteer.contact.first_name, mail_body
    assert_match @volunteer.contact.last_name, mail_body
    assert_match @volunteer.contact.postal_code, mail_body
    assert_match @volunteer.contact.city, mail_body
    assert_match I18n.l(@volunteer.birth_year), mail_body
    assert_match 'Bogus Education', mail_body
    assert_match 'Woman', mail_body
  end

  test 'trial_period_mailer' do
    _, _, group_assignments = create_group_offer_entity(
      nil, 7.weeks.ago, nil, create(:volunteer_with_user), create(:volunteer_with_user)
    )
    assignment = make_assignment(start_date: 7.weeks.ago)
    mailing = create_probation_mailing(*group_assignments, assignment)
    mailing.reminder_mailing_volunteers.each do |rmv|
      mailer = VolunteerMailer.trial_period_reminder(rmv).deliver
      assert_equal rmv.process_template[:subject], mailer.subject
      assert mailer.to.include? rmv.volunteer.contact.primary_email
      assert_match rmv.process_template[:body], mailer.body.encoded
    end
  end

  test 'half_year_mailer' do
    _, _, group_assignments = create_group_offer_entity(
      nil, 8.months.ago, nil, create(:volunteer_with_user), create(:volunteer_with_user)
    )
    assignment = make_assignment(start_date: 8.months.ago)
    mailing = create_half_year_mailing(*group_assignments, assignment)
    mailing.reminder_mailing_volunteers.each do |rmv|
      mailer = VolunteerMailer.half_year_reminder(rmv).deliver
      assert_equal rmv.process_template[:subject], mailer.subject
      assert mailer.to.include? rmv.volunteer.contact.primary_email
      assert_match rmv.process_template[:body], mailer.body.encoded
    end
  end
end
