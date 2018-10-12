class Semester
  # params:
  #   context - default is now, but optionally any other point in time
  def initialize(year = nil, semester_number = nil)
    @context = if year && semester_number == 2
                 Time.zone.local(year, 6, 1)
               elsif year && semester_number == 1
                 Time.zone.local(year - 1, 12, 1)
               else
                 Time.zone.now
               end
  end

  def number(date_time = nil)
    if (6..11).cover?(date_time&.month || @context.month)
      2
    else
      1
    end
  end

  def year_number(count: 1, direction: :previous, set_semester: nil)
    string_semester = set_semester || public_send(direction, count)
    "#{string_semester.end.year},#{number(string_semester.end)}"
  end

  # running semester where in now
  def current
    @current ||= semester_range_from_start(semester_start_time(@context))
  end

  # params:
  #   count - shift of semesters - only positive integers
  def previous(count = 1)
    return current if count == 0

    current.begin.advance(months: -(6 * count))..current.end.advance(months: -(6 * count))
  end

  # params:
  #   count - shift of semesters - only positive integers
  def next(count = 1)
    return current if count == 0

    current.begin.advance(months: 6 * count)..current.end.advance(months: 6 * count)
  end

  # list of semester datetime ranges
  #
  # params:
  #   count - amount of semesters
  #   direction - [:next || :previous]
  #   with_current - include current semester as first in array
  def list(count = 3, direction = :previous, with_current: true)
    list = (1..count).to_a.map do |step|
      public_send(direction, step)
    end
    if with_current
      [current] + list
    else
      list
    end
  end

  def collection(count = 3, direction = :previous, with_current: true)
    list(count, direction, with_current: with_current).map do |semester|
      semester_number = number(semester.end)
      semester_year = semester.end.year
      [
        "#{semester_number}. Semester #{semester_year} (#{I18n.l(semester.begin.to_date)} - #{I18n.l(semester.end.to_date)})",
        year_number(set_semester: semester)
      ]
    end
  end

  private

  def semester_start_time(date_time)
    if (6..11).cover?(date_time.month)
      Time.zone.local(date_time.year, 6, 1)
    elsif date_time.month == 12
      Time.zone.local(date_time.year, 12, 1)
    else
      Time.zone.local(date_time.year - 1, 12, 1)
    end
  end

  def semester_range_from_start(date_time)
    date_time..date_time.advance(months: 5).end_of_month
  end
end
