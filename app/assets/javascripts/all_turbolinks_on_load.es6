$(() => $(document).on('turbolinks:render, turbolinks:load', () => {
  truncateModal();
  dateTimePicker();
  conditionalField();
  mailingsSelectAll();
  volunteerForm();
  groupOfferForm();
}));
