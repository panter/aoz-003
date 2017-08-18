$(() => {
  $(document).on('turbolinks:render, turbolinks:load', () => {
    $('.input-daterange input').datepicker({
      format: "yyyy-mm-dd",
      clearBtn: true,
      language: "de",
      calendarWeeks: true,
      autoclose: true,
      todayHighlight: true
    });
  });
});
