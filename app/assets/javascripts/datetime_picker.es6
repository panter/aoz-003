$(() => {
  $(document).on('turbolinks:render, turbolinks:load', () => {
    const datepickers = $('.input-daterange input').datepicker({
      format: "yyyy-mm-dd",
      startView: 1,
      todayBtn: true,
      clearBtn: true,
      language: "de",
      calendarWeeks: true,
      autoclose: true,
      todayHighlight: true,
      toggleActive: true
    });
    console.log(datepickers)
  });
});
