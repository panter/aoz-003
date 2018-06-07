function inplaceFields() {
  $('.inplace_field').each((index, field) => {
    let $fieldLabel = $(field).find('.field_label');
    let $fieldInput = $(field).find('.field_input');

    $fieldLabel.on('click', ({target}) => {
      $(field).addClass('editing');

      let $editingField = $fieldInput.find('input')
      $editingField.focus();
      $editingField.on('blur', ({target}) => {
        $(field).removeClass('editing');
      });
    });
  });
}

