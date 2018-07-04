$(() => {
  if (window.location.pathname.split('/')[3] === 'last_submitted_hours_and_feedbacks') {
    enableWaiveFormXhrSubmit()
  }
})

const updateFieldXhr = ({ fieldName, volunteerId, targetElement }) => {
  $.ajax({
    data: { volunteer: { [fieldName]: valueOrChecked(targetElement) } },
    method: 'PATCH',
    dataType: 'json',
    url: Routes.update_waive_and_iban_volunteer_path(volunteerId)
  }).always(() => targetElement.on('input', ({ target }) => inputHandler({ target, fieldName, volunteerId })))
}

const valueOrChecked = field => (field.prop('type') === 'checkbox') ? field.prop('checked') : field.val();

const inputHandler = ({ target, fieldName, volunteerId }) => {
  const targetElement = $(target);
  targetElement.off('input')
  updateFieldXhr({ fieldName, volunteerId, targetElement })
}

const enableWaiveFormXhrSubmit = () => {
  const waiveIbanForm = $('#volunteer-update-waive-and-iban')
  const volunteerId = waiveIbanForm.find('input[name$="assignment[volunteer_attributes][id]"]').val()
  const formFields = ['waive', 'iban', 'bank'].map(fieldName => (
    [fieldName, waiveIbanForm.find(`input[name$="assignment[volunteer_attributes][${fieldName}]"]`)]
  )).map(([fieldName, inputElement]) => {
    $(inputElement).on('input', ({ target }) => inputHandler({ target, fieldName, volunteerId }))
    return [fieldName, inputElement]
  })
}
