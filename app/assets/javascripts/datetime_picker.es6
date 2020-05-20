$(() => {
  const datePickerDefaults = {
    format: 'dd.mm.yyyy',
    todayBtn: true,
    clearBtn: true,
    language: 'de',
    autoclose: true,
    todayHighlight: true,
    daysOfWeekHighlighted: [0, 6],
    immediateUpdates: true,
  }

  $('.input-daterange input').datepicker({
    ...datePickerDefaults,
    startView: 1,
  })

  $('.input-date-picker input, .bs-datepicker-input').datepicker(
    datePickerDefaults
  )

  $('#performance_report_period_years li a').each((_index, element) => {
    $(element).click((event) => {
      event.preventDefault()
      $('#performance_report_period_start').datepicker(
        'update',
        `01.01.${$(element).data().year}`
      )
      $('#performance_report_period_end').datepicker(
        'update',
        `31.12.${$(element).data().year}`
      )
    })
  })
})
