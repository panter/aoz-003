$(document).on('turbolinks:load', () => {
  $("input[data-autocomplete]").each((_index, input) => {
    $(input).autocomplete({ source: $(input).data('autocomplete'), close: ({target}) => {
      // if autocomplete placed value in field and closed submit the form
      if(target.value.length > 4) {
        $(target).parent('form').submit();
      }
    }});

    // Select all text in input, for easyer deleting of all content if desired
    $(input).on('focus', ({target}) => {
      $(target).select();
    });
  });
});
