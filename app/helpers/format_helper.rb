module FormatHelper
  def format_currency(amount)
    number_to_currency amount, unit: 'Fr.', format: '%u %n', separator: '.', delimiter: "'"
  end

  def format_hours(hours)
    hours = hours.to_i if (hours % 1).zero?
    t('activerecord.attributes.billing_expense.hours', count: hours)
  end

  def format_hours_semester(hours)
    return '' if hours.blank?
    dates = hours.map(&:meeting_date)
    if dates.size > 1
      return format_hours_multiple_dates_semester(dates)
    end
    '%s. Semester %s' % [
      BillingExpense.semester_of_year(dates.first),
      BillingExpense.semester_display_year(dates.first)
    ]
  end

  def format_hours_multiple_dates_semester(dates)
    min_date = dates.min
    min_year = BillingExpense.semester_display_year(min_date)
    min_semester = BillingExpense.semester_of_year(min_date)
    max_date = dates.max
    max_year = BillingExpense.semester_display_year(max_date)
    max_semester = BillingExpense.semester_of_year(max_date)
    if max_year != min_year
      '%i. Semester %i – %i. Semester %i' % [min_semester, min_year, max_semester, max_year]
    elsif min_semester == max_semester
      '%i. Semester %i' % [max_semester, max_year]
    else
      '%i. – %i. Semester %i' % [min_semester, max_semester, max_year]
    end
  end
end
