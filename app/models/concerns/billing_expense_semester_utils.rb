module BillingExpenseSemesterUtils
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    def self.semester_of_year(date)
      if (6..11).cover? date.month
        2
      else
        1
      end
    end

    def self.semester_display_year(date)
      if date.month == 12
        date.year + 1
      else
        date.year
      end
    end

    def self.semester_back_count(first_date, last_date)
      ((last_date.to_f - first_date.to_f) / BillingExpense::SEMESTER_LENGTH.months.to_f).ceil.to_i
    end

    def self.semester_from_hours(hours, date_position: :maximum)
      if hours.blank?
        current_semester_start
      elsif hours.count > 1
        dates_semester_start(hours.public_send(date_position, :meeting_date))
      else
        dates_semester_start(hours.first.meeting_date)
      end
    end

    def self.billing_expense_semester(date)
      if date.blank?
        current_semester_start
      else
        billable_semester_date(date)
      end
    end

    def self.billable_semester_date(date)
      if date.blank?
        nil
      elsif date.is_a?(Time)
        date.beginning_of_day
      else
        Time.zone.parse(date).beginning_of_day
      end
    end

    def self.dates_semester_start(date)
      if semester_of_year(date) == 2
        Time.zone.parse("#{date.year}-06-01").beginning_of_day
      elsif date.month == 12
        Time.zone.parse("#{date.year}-12-01").beginning_of_day
      else
        Time.zone.parse("#{date.year - 1}-12-01").beginning_of_day
      end
    end

    def self.current_semester_start
      @current_semester_start ||= dates_semester_start(Time.zone.now)
    end
  end
end
