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
    return format_hours_multiple_dates_semester(dates) if dates.size > 1
    I18n.t('semester.one_semester', number: BillingExpense.semester_of_year(dates.first),
      year: BillingExpense.semester_display_year(dates.first))
  end

  def format_hours_multiple_dates_semester(dates)
    min_date = dates.min
    min_year = BillingExpense.semester_display_year(min_date)
    min_semester = BillingExpense.semester_of_year(min_date)
    max_date = dates.max
    max_year = BillingExpense.semester_display_year(max_date)
    max_semester = BillingExpense.semester_of_year(max_date)
    if max_year != min_year
      '%s – %s' % [
        I18n.t('semester.one_semester', number: min_semester, year: min_year),
        I18n.t('semester.one_semester', number: max_semester, year: max_year)
      ]
    elsif min_semester == max_semester
      I18n.t('semester.one_semester', number: max_semester, year: max_year)
    else
      I18n.t('semester.two_semesters_same_year', year: max_year)
    end
  end
end
