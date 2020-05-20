function inplaceFields() {
  $('.inplace_field').each((index, field) => {
    const $fieldLabel = $(field).find('.field_label')
    const $fieldInput = $(field).find('.field_input')

    $fieldLabel.on('click', () => {
      $(field).addClass('editing')

      const $editingField = $fieldInput.find('input')
      $editingField.focus()
      $editingField.on('blur', () => {
        $(field).removeClass('editing')
      })
    })
  })
}
