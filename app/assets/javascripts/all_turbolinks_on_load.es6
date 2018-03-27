$(() => $(document).on('turbolinks:render, turbolinks:load', () => {
  truncateModal();
  dateTimePicker();
  conditionalField();
  tableRowSelectable();
  volunteerForm();
  groupOfferForm();
}));
