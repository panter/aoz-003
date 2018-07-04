$(() => {
  if (_(window.location.pathname).split('/').last() === 'last_submitted_hours_and_feedbacks') {
    enableWaiveFormXhrSubmit()
  }
})

const throttle = (callBack, time = 1000) => _.throttle(callBack, time)

const enableWaiveFormXhrSubmit = () => {
  const waiveIbanForm = $('#volunteer-update-waive-and-iban')
  const volunteerId = waiveIbanForm.find('input[name$="assignment[volunteer_attributes][id]"]').val()
  _(['waive', 'iban', 'bank']).map(fieldName => {
    return {
      fieldElement: waiveIbanForm.find(`input[name$="assignment[volunteer_attributes][${fieldName}]"]`),
      fieldName
    }
  }).forEach(({ fieldElement, fieldName }) => {
    $(fieldElement).on('input', throttle(({ target }) => {
      $.ajax({
        data: { volunteer: { [fieldName]: valueOrChecked($(target)) } },
        method: 'PATCH',
        dataType: 'json',
        url: Routes.update_waive_and_iban_volunteer_path(volunteerId)
      })
    }))
  })
}

const valueOrChecked = field => (field.prop('type') === 'checkbox') ? field.prop('checked') : field.val();
