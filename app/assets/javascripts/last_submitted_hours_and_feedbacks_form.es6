$(() => {
  const waiveIbanForm = $('#volunteer-update-waive-and-iban')
  if (waiveIbanForm.length === 0) { return }
  const volunteerId = waiveIbanForm.find('input[name$="assignment[volunteer_attributes][id]"]').val()
  _(['iban', 'bank']).forEach(fieldName => {
    waiveIbanForm.find(`input[name$="assignment[volunteer_attributes][${fieldName}]"]`)
      .on('input', throttle(({ target }) => {
        updateBankDetails({ fieldName, target, volunteerId })
    }))
  })
  waiveIbanForm.find(`input[name$="assignment[volunteer_attributes][waive]"]`)
    .on('change', throttle(({ target }) => {
      updateBankDetails({ fieldName: 'waive', target, volunteerId })
    }))
})

const updateBankDetails = ({ fieldName, target, volunteerId }) => {
  $.ajax({
    data: { volunteer: { [fieldName]: valueOrChecked($(target)) } },
    method: 'PATCH',
    dataType: 'json',
    url: Routes.update_bank_details_volunteer_path(volunteerId)
  })
}

const throttle = (callBack, time = window.THROTTLE_TIMEOUT) => _.throttle(callBack, time)

const valueOrChecked = field => field.is(':checkbox') ? field.is(':checked') : field.val();
