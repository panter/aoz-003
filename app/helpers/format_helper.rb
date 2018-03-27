module FormatHelper
  def format_currency(amount)
    number_to_currency amount, unit: 'Fr.', format: '%u %n', separator: '.', delimiter: "'"
  end

  def format_hours(hours)
    hours = hours.to_i if (hours % 1).zero?
    pluralize hours, 'Stunde', 'Stunden'
  end

  def format_hours_period(hours)
    dates = hours.map(&:meeting_date)
    "#{I18n.l dates.min} - #{I18n.l dates.max}"
  end
end
