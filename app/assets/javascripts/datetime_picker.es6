function dateTimePicker() {
  const datepickers = $('.input-daterange input').datepicker({
    format: 'dd.mm.yyyy',
    startView: 1,
    todayBtn: true,
    clearBtn: true,
    language: 'de',
    autoclose: true,
    todayHighlight: true,
    daysOfWeekHighlighted: [0,6],
    immediateUpdates: true
  });

  const datepickersSingle = $('.input-date-picker input').datepicker({
    format: 'dd.mm.yyyy',
    todayBtn: true,
    clearBtn: true,
    language: 'de',
    autoclose: true,
    todayHighlight: true,
    daysOfWeekHighlighted: [0,6],
    immediateUpdates: true
  });
  $('#performance_report_period_years li a').each((index, element) => {
    $(element).bind('click', (event) => {
      event.preventDefault();
      $('#performance_report_period_start').datepicker('update', `${$(element).data().year}-01-01`);
      $('#performance_report_period_end').datepicker('update', `${$(element).data().year}-12-31`);
    });
  });
}
