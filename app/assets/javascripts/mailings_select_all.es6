$(() => $(document).on('turbolinks:render, turbolinks:load', () => {

  $('table.reminder-select tbody tr td:nth-child(n + 2)').on('click', event => {
    event.stopPropagation();
    const row = $(event.target).closest('tr');
    const selectBox = $(`#reminder_mailing_reminder_mailing_volunteers_attributes_${row.data().index}_selected`)[0];
    if (selectBox.checked) {
      row.removeClass('mailing-selected');
      $(selectBox).prop('checked', false);
    } else {
      row.addClass('mailing-selected');
      $(selectBox).prop('checked', true);
    }
  });

  const selectedBoxes = $('input.boolean[id$="_selected"]');
  selectedBoxes.on('change', ({target}) => {
    const row = $(target).closest('tr');
    if (target.checked) {
      row.addClass('mailing-selected');
    } else
      row.removeClass('mailing-selected');
    }
  );
  $('.select-all-mailings input[type="checkbox"]').on('change', ({target}) => {

    const mailingRows = $('.reminder-select tbody tr');
    if (target.checked) {
      mailingRows.addClass('mailing-selected');
      selectedBoxes.prop('checked', true);
    } else {
      mailingRows.removeClass('mailing-selected');
      selectedBoxes.prop('checked', false);
    }
  });

}));
