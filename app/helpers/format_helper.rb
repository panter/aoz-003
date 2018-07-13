module FormatHelper
  def format_currency(amount)
    number_to_currency amount, unit: 'Fr.', format: '%u %n', separator: '.', delimiter: "'"
  end

  def format_hours(hours)
    t('activerecord.attributes.billing_expense.hours', count: hours.to_i)
  end

  def format_hours_semester(hours)
    return '' if hours.blank?
    dates = hours.map(&:meeting_date)
    if dates.size == 1
      "#{BillingExpense.semester_of_year(dates.first)}. Semester #{semester_display_year(dates.first)}"
    else
      format_hours_multiple_dates_semester(dates)
    end
  end

  def format_hours_multiple_dates_semester(dates)
    min_date = dates.min
    max_date = dates.max
    if semester_display_year(min_date) != semester_display_year(max_date)
      "#{BillingExpense.semester_of_year(min_date)}. Semester #{semester_display_year(min_date)} - "\
        "#{BillingExpense.semester_of_year(max_date)}. Semester #{max_date.year}"
    elsif BillingExpense.semester_of_year(min_date) == BillingExpense.semester_of_year(max_date)
      "#{BillingExpense.semester_of_year(max_date)}. Semester #{semester_display_year(max_date)}"
    else
      "#{BillingExpense.semester_of_year(min_date)}. - "\
        "#{BillingExpense.semester_of_year(max_date)}. Semester #{semester_display_year(max_date)}"
    end
  end

  def semester_display_year(date)
    if date.month == 12
      date.year + 1
    else
      date.year
    end
  end
end
