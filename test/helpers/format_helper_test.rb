require 'test_helper'

class FormatHelperTest < ActionView::TestCase
  test 'format_currency' do
    assert_equal 'Fr. 2.35', format_currency(2.35)
    assert_equal 'Fr. 1.00', format_currency(1)
  end

  test 'format_hours' do
    assert_equal '1 Stunde', format_hours(1)
    assert_equal '1.1 Stunden', format_hours(1.1)
    assert_equal '0.9 Stunden', format_hours(0.9)
    assert_equal '2.35 Stunden', format_hours(2.35)
  end

  test 'format_hours_period' do
    assert_equal '01.02.2013 - 03.04.2015', format_hours_period([
      create(:hour, meeting_date: '2015-04-03'),
      create(:hour, meeting_date: '2014-05-06'),
      create(:hour, meeting_date: '2013-02-01')
    ])
  end
end
