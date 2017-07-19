$(() => {
  $(document).on('turbolinks:render, turbolinks:load', () => {
    const select_selector = '#relatives select[name$="[relation]"]';
    const selectize_options = {
      allowEmptyOption: true
    }
    $(select_selector).selectize(selectize_options);
    $('.add-relation-button').bind('click', ({target}) => {
      setTimeout(() => {
        $(select_selector).selectize(selectize_options);
      }, 0);
    });
  });
});
