const updateFieldXhr = ({ fieldName, fieldValue, volunteerId, authToken, targetElement }) => {
  const volunteer = {};
  volunteer[fieldName] = fieldValue;
  $.ajax({
    data: { volunteer },
    method: 'PATCH',
    dataType: 'json',
    headers: { 'X-CSRF-Token': authToken },
    url: `/volunteers/${volunteerId}/update_waive_and_iban`
  }).done(() => {
    targetElement.on('input', ({ target }) => inputHandler({ target, fieldName, volunteerId, authToken }))
  }).fail(error => {
    console.log(error)
    targetElement.on('input', ({ target }) => inputHandler({ target, fieldName, volunteerId, authToken }))
  })
}

const valueOrChecked = field => (field.prop('type') === 'checkbox') ? field.prop('checked') : field.val();

const inputHandler = ({ target, fieldName, volunteerId, authToken }) => {
  const targetElement = $(target);
  targetElement.off('input')
  updateFieldXhr({ fieldName, fieldValue: valueOrChecked(targetElement), volunteerId, authToken, targetElement })
}

const lastSubmittedHoursAndFeedbacksForm = () => {
  const authToken = $('input[name="authenticity_token"]').val()
  const waiveIbanForm = $('#volunteer-update-waive-and-iban')
  const volunteerId = waiveIbanForm.find('input[name$="assignment[volunteer_attributes][id]"]').val()
  const formFields = ['waive', 'iban', 'bank'].map(fieldName => (
    [fieldName, waiveIbanForm.find(`input[name$="assignment[volunteer_attributes][${fieldName}]"]`)]
  ))

  formFields.map(([fieldName, inputElement]) => {
    $(inputElement).on('input', ({ target }) => inputHandler({ target, fieldName, volunteerId, authToken }))
  })
}
