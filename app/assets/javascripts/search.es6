$(() => {
  $("input[data-autocomplete]").each((_index, input) => {
    $(input).autocomplete({
      source: $(input).data('autocomplete'),
      close: handleCloseAutosuggest,
      focus: handleAutosuggestFocus
    });

    // Select all text in input, for easier deleting of all content if desired
    $(input).on('focus', ({target}) => $(target).select());
  });
});

const handleCloseAutosuggest = ({target}) => {
  // if autocomplete placed value in field and closed submit the form
  if(target.value.length > 4) {
    $(target).parent('form').submit();
  }
  return false;
}

const handleAutosuggestFocus = (event, ui) => {
  $("#project").val(ui.item.label);
  return false;
}
