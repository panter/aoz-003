require 'test_helper'

class SemesterServiceTest < ActionView::TestCase
  test '#initialize' do
    subject = Semester.new
    assert_equal Time.zone.now.to_date, subject.context.to_date

    subject = Semester.new(2018, 2)
    assert_equal time_z(2018, 6, 1), subject.context

    subject = Semester.new(2018, 1)
    assert_equal time_z(2017, 12, 1), subject.context
  end

  test '#to_s' do
    travel_to time_z(2018, 8, 10)
    subject = Semester.new
    assert_equal '2018,2', subject.to_s

    travel_to time_z(2017, 12, 10)
    subject = Semester.new
    assert_equal '2018,1', subject.to_s

    travel_to time_z(2018, 2, 10)
    subject = Semester.new
    assert_equal '2018,1', subject.to_s
  end

  test '#number' do
    travel_to time_z(2018, 8, 10)
    subject = Semester.new
    assert_equal 2, subject.number
    travel_to time_z(2018, 4, 10)
    subject = Semester.new
    assert_equal 1, subject.number
    travel_to time_z(2017, 12, 10)
    subject = Semester.new
    assert_equal 1, subject.number

    assert_equal 1, subject.number(time_z(2010, 12, 23))
    assert_equal 1, subject.number(time_z(2010, 1, 23))
    assert_equal 2, subject.number(time_z(2010, 7, 30))

    assert_equal 1, subject.number(time_z(2010, 12, 1).to_date..time_z(2010, 5, 1).end_of_month.to_date)
    assert_equal 2, subject.number(time_z(2010, 6, 1).to_date..time_z(2010, 11, 1).end_of_month.to_date)
  end

  test '#current' do
    travel_to time_z(2018, 8, 10)
    subject = Semester.new
    assert_equal time_z(2018, 6, 1).to_date..time_z(2018, 11, 1).end_of_month.to_date, subject.current

    subject = Semester.new(2017, 2)
    assert_equal time_z(2017, 6, 1).to_date..time_z(2017, 11, 1).end_of_month.to_date, subject.current

    subject = Semester.new(2017, 1)
    assert_equal time_z(2016, 12, 1).to_date..time_z(2017, 5, 1).end_of_month.to_date, subject.current
  end

  test '#previous' do
    travel_to time_z(2018, 8, 10)

    subject = Semester.new
    assert_equal time_z(2017, 12, 1).to_date..time_z(2018, 5, 1).end_of_month.to_date, subject.previous
    assert_equal time_z(2017, 6, 1).to_date..time_z(2017, 11, 1).end_of_month.to_date, subject.previous(2)
    assert_equal time_z(2016, 12, 1).to_date..time_z(2017, 5, 1).end_of_month.to_date, subject.previous(3)
  end

  test '#next_semester' do
    travel_to time_z(2018, 8, 10)

    subject = Semester.new
    assert_equal time_z(2018, 12, 1).to_date..time_z(2019, 5, 1).end_of_month.to_date, subject.next_semester
    assert_equal time_z(2019, 6, 1).to_date..time_z(2019, 11, 1).end_of_month.to_date, subject.next_semester(2)
    assert_equal time_z(2019, 12, 1).to_date..time_z(2020, 5, 1).end_of_month.to_date, subject.next_semester(3)
  end

  test '#previous_s' do
    travel_to time_z(2018, 8, 10)

    subject = Semester.new
    assert_equal '2018,1', subject.previous_s
    assert_equal '2017,2', subject.previous_s(2)
    assert_equal '2017,1', subject.previous_s(3)
  end

  test '#next_s' do
    travel_to time_z(2018, 8, 10)

    subject = Semester.new
    assert_equal '2019,1', subject.next_s
    assert_equal '2019,2', subject.next_s(2)
    assert_equal '2020,1', subject.next_s(3)
  end

  test '#list' do
    travel_to time_z(2018, 8, 10)

    subject = Semester.new
    assert_equal [
      time_z(2018, 6, 1).to_date..time_z(2018, 11, 1).end_of_month.to_date,
      time_z(2017, 12, 1).to_date..time_z(2018, 5, 1).end_of_month.to_date,
      time_z(2017, 6, 1).to_date..time_z(2017, 11, 1).end_of_month.to_date,
      time_z(2016, 12, 1).to_date..time_z(2017, 5, 1).end_of_month.to_date
    ], subject.list

    assert_equal [
      time_z(2018, 6, 1).to_date..time_z(2018, 11, 1).end_of_month.to_date,
      time_z(2017, 12, 1).to_date..time_z(2018, 5, 1).end_of_month.to_date,
      time_z(2017, 6, 1).to_date..time_z(2017, 11, 1).end_of_month.to_date
    ], subject.list(2)

    assert_equal [
      time_z(2017, 12, 1).to_date..time_z(2018, 5, 1).end_of_month.to_date,
      time_z(2017, 6, 1).to_date..time_z(2017, 11, 1).end_of_month.to_date,
      time_z(2016, 12, 1).to_date..time_z(2017, 5, 1).end_of_month.to_date
    ], subject.list(with_current: false)

    assert_equal [
      time_z(2018, 6, 1).to_date..time_z(2018, 11, 1).end_of_month.to_date,
      time_z(2018, 12, 1).to_date..time_z(2019, 5, 1).end_of_month.to_date,
      time_z(2019, 6, 1).to_date..time_z(2019, 11, 1).end_of_month.to_date,
      time_z(2019, 12, 1).to_date..time_z(2020, 5, 1).end_of_month.to_date
    ], subject.list(direction: :next_semester)
  end

  test '#collection' do
    travel_to time_z(2018, 8, 10)

    subject = Semester.new
    assert_equal [
      collection_entry(2, 2018, time_z(2018, 6, 1).to_date, time_z(2018, 11, 1).end_of_month.to_date),
      collection_entry(1, 2018, time_z(2017, 12, 1).to_date, time_z(2018, 5, 1).end_of_month.to_date),
      collection_entry(2, 2017, time_z(2017, 6, 1).to_date, time_z(2017, 11, 1).end_of_month.to_date),
      collection_entry(1, 2017, time_z(2016, 12, 1).to_date, time_z(2017, 5, 1).end_of_month.to_date),
    ], subject.collection
  end

  def collection_entry(number, year, start, end_d)
    ["#{number}. Semester #{year} (#{I18n.l(start.to_date)} - #{I18n.l(end_d.to_date)})", "#{year},#{number}"]
  end

end
