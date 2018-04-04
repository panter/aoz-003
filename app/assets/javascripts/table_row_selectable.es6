function tableRowSelectable() {
  var rows = $('tr.table-row-selectable');

  rows.on('click', event => {
    var row = $(event.currentTarget);
    var checkbox = row.find(':checkbox:first');
    var selected = checkbox.is(':checked');

    if (checkbox.is(':disabled')) {
      return;
    }

    if ($(event.target).is(checkbox)) {
      selected = !selected;
    } else {
      checkbox.prop({ checked: !selected });
    }

    row.toggleClass('success', !selected);
  });

  // open links in new tabs, don't select when clicking on them
  var links = rows.find('a');
  links.attr({ target: '_blank' });
  links.on('click', event => {
    event.stopPropagation();
  });

  // toggle all rows
  $('.table-row-select-all').on('click', function() {
    if ($(this).is(':checked')) {
      rows.find(':checkbox:not(:checked)').click();
    } else {
      rows.find(':checkbox:checked').click();
    }
  });

  // restore state on page load
  rows.find(':checkbox:checked:not(:disabled)').each(function() {
    $(this).closest('tr').addClass('success');
  });
}
