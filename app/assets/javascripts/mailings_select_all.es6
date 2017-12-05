function mailingsSelectAll() {

  $('.reminder-select .click-selecting').on('click', event => {
    event.stopPropagation();
    const row = $(event.target).closest('tr');
    const selectBox = $(`#reminder_mailing_reminder_mailing_volunteers_attributes_${row.data().index}_picked`);
    row.toggleClass('mailing-selected', !selectBox.is(':checked'));
    selectBox.prop('checked', !selectBox.is(':checked'));
  });

  const selectedBoxes = $('input.boolean[id$="_picked"]');
  selectedBoxes.on('change', ({target, preventDefault}) => {
    preventDefault();
    target = $(target);
    target.prop('checked', !target.is(':checked'));
    const row = $(target).closest('tr');
    row.toggleClass('mailing-selected', target.is(':checked'));
  });

  $('.select-all-mailings input[type="checkbox"]').on('change', ({target}) => {
    const mailingRows = $('.reminder-select tbody tr');
    mailingRows.toggleClass('mailing-selected', target.checked);
    selectedBoxes.prop('checked', target.checked);
  });
}
