$(() => {
  const waiveIbanForm = $('#volunteer-update-waive-and-iban')
  if (waiveIbanForm.length === 0) { return }
  const volunteerId = waiveIbanForm.find('input[name$="assignment[volunteer_attributes][id]"]').val()
  _(['waive', 'iban', 'bank']).forEach(fieldName => {
    waiveIbanForm.find(`input[name$="assignment[volunteer_attributes][${fieldName}]"]`).on('input', throttle(({ target }) => {
      $.ajax({
        data: { volunteer: { [fieldName]: valueOrChecked($(target)) } },
        method: 'PATCH',
        dataType: 'json',
        url: Routes.update_waive_and_iban_volunteer_path(volunteerId)
      })
    }))
  })
})

const valueOrChecked = field => field.is(':checkbox') ? field.is(':checked') : field.val();
