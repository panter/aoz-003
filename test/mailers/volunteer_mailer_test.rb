require 'test_helper'

class VolunteerMailerTest < ActionMailer::TestCase
  def setup
    @volunteer = create :volunteer, education: 'Bogus Education', woman: true
    @volunteer_email = create :volunteer_email
  end

  test 'volunteer welcome mail with confirmation data is sent correctly' do
    # FIXME: Problem with umlauts, but only in tests. Test doesn't recognize
    # email encoded utf-8 umlauts
    @volunteer.contact.city = 'Zuerich'
    @volunteer.save
    mailer = VolunteerMailer.welcome_email(@volunteer, @volunteer_email).deliver
    assert_equal @volunteer_email.subject, mailer.subject
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
end
