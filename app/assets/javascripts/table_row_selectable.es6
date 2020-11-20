function tableRowSelectable() {
  var rows = $('tr.table-row-selectable')

  rows.on('change', ':checkbox:first', (event) => {
    var checkbox = $(event.target)
    var row = checkbox.closest('tr')
    var selected = !checkbox.is(':checked')

    if (checkbox.is(':disabled')) {
      return
    }

    row.toggleClass('success', !selected)
  })

  // toggle all rows
  $('.table-row-select-all').on('click', function () {
    if ($(this).is(':checked')) {
      rows.find(':checkbox:not(:disabled, :checked)').click()
    } else {
      rows.find(':checkbox:checked').click()
    }
  })

  // restore state on page load
  rows.find(':checkbox:checked:not(:disabled)').each(function () {
    $(this).closest('tr').addClass('success')
  })
}
