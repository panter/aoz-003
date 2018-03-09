$(() => {
  $(document).on('turbolinks:render, turbolinks:load', () => {
    const select_selector = '#event_volunteer_volunteer_id';
    $(select_selector).selectize();
  });
});
