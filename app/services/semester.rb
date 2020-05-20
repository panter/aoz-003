class Semester
  attr_reader :context

  MONTH_NUMBER_MAP = {
    12 => 1,
    1 => 1,
    2 => 1,
    3 => 1,
    4 => 1,
    5 => 1,
    6 => 2,
    7 => 2,
    8 => 2,
    9 => 2,
    10 => 2,
    11 => 2
  }.freeze

  class << self
    def parse(string)
      return unless string

      year, number = string.split(',').map(&:to_i)
      year -= 1 if number == 1
      start_date = Time.zone.local(year, (18 - number * 6), 1)
      semester_range_from_start(start_date)
    end

    def to_s(date = nil)
      date = to_process_date(date)
      "#{year(date)},#{number(date)}"
    end

    def number(date = nil)
      date = to_process_date(date)
      MONTH_NUMBER_MAP[date.month]
    end

    def taken_semesters
      SemesterProcess.all.pluck(:semester)
    end

    def year(date = nil)
      date = to_process_date(date)
      date.month == 12 ? date.year + 1 : date.year
    end

    def to_process_date(date)
      if date.blank?
        Time.zone.now
      elsif date.is_a?(Range)
        date.end
      else
        date
      end
    end

    def i18n_t(semester, short: true)
      if short
        I18n.t(:semester_short, number: number(semester), year: year(semester))
      else
        I18n.t(:semester_long, number: number(semester), year: year(semester), begin: I18n.l(semester.begin.to_date),
          end: I18n.l(semester.end.to_date))
      end
    end

    def period(semester)
      I18n.t(:semester_period, begin: I18n.l(semester.begin.to_date), end: I18n.l(semester.end.to_date))
    end

    def semester_start_time(date_time)
      date_time = date_time.to_date
      if (6..11).cover?(date_time.month)
        Time.zone.local(date_time.year, 6, 1)
      elsif date_time.month == 12
        Time.zone.local(date_time.year, 12, 1)
      else
        Time.zone.local(date_time.year - 1, 12, 1)
      end
    end

    def semester_range_from_start(date_time)
      date_time = date_time.to_date
      date_time...date_time.advance(months: 5).end_of_month
    end
  end

  # params:
  #   year - integer of year
  #   semester_number - required if year integer
  def initialize(year = nil, number = 1)
    @context = if year.nil?
                 Time.zone.now
               else
                 year -= 1 if number == 1
                 Time.zone.local(year, (18 - number * 6), 1)
               end
  end

  def year(date = nil)
    Semester.year(date || @context)
  end

  def to_s(date = nil)
    Semester.to_s(date || @context)
  end

  def number(date = nil)
    Semester.number(date || @context)
  end

  # running semester where in now
  def current
    @current ||= Semester.semester_range_from_start(
      Semester.semester_start_time(@context)
    )
  end

  def preselect_semester
    previous
  end

  # params:
  #   count - shift of semesters - only positive integers
  def previous(count = 1)
    return current if count == 0

    Semester.semester_range_from_start(current.begin.advance(months: -6 * count))
  end

  def previous_s(count = 1)
    to_s(previous(count))
  end

  # params:
  #   count - shift of semesters - only positive integers
  def next_semester(count = 1)
    return current if count == 0

    Semester.semester_range_from_start(current.begin.advance(months: 6 * count))
  end

  def next_s(count = 1)
    to_s(next_semester(count))
  end

  # list of semester datetime ranges
  #
  # params:
  #   count - amount of semesters
  #   direction - [:next_semester || :previous]
  #   with_current - include current semester as first in array
  def list(count = 3, direction: :previous, with_current: true)
    list = (1..count).to_a.map do |step|
      public_send(direction, step)
    end
    if with_current
      [current] + list
    else
      list
    end
  end

  def collection(count = 3, direction: :previous, with_current: true)
    list(count, direction: direction, with_current: with_current).map do |semester|
      if block_given?
        yield semester
      else
        [Semester.i18n_t(semester, short: false), to_s(semester)]
      end
    end.compact
  end

  def unique_collection(count = 3)
    collection(count) do |semester|
      next if Semester.taken_semesters.include?(semester)

      [Semester.i18n_t(semester, short: false), to_s(semester)]
    end
  end

  def existing_collection(count = 6)
    collection(count) do |semester|
      s = Semester.new
      next unless s.preselect_semester == semester || s.current == semester || Semester.taken_semesters.include?(semester)

      [Semester.i18n_t(semester, short: false), to_s(semester)]
    end
  end
end
