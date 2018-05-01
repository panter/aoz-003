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
      $('#performance_report_period_start').datepicker('update', `01.01.${$(element).data().year}`);
      $('#performance_report_period_end').datepicker('update', `31.12.${$(element).data().year}`);
    });
  });
}
