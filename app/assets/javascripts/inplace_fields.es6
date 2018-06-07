function inplaceFields() {
  $('.inplace_field').each((index, field) => {
    let $fieldLabel = $(field).find('.field_label');
    let $fieldInput = $(field).find('.field_input');

    finishEditing(field);

    $fieldLabel.on('click', ({target}) => {
      startEditing(field);
    });

    $fieldInput.on('ajax:success', ({target}) => {
      finishEditing(field);
    });
  });
}

const startEditing = (field) => {
  $(field).addClass('editing');
}

const finishEditing = (field) => {
  $(field).removeClass('editing');
}
