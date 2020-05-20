function volunteerForm() {
  show_rejection()
  toggleOtherInput(
    $('#other-offer label input').length > 0
      ? $('#other-offer label input')[0]
      : null
  )

  $('#volunteer_acceptance').on('change load', ({ target }) =>
    show_rejection(target)
  )

  $('#other-offer label input').on('change', ({ target }) => {
    toggleOtherInput(target)
  })

  $('.volunteer-active-checkbox-changes').on('change', ({ target }) => {
    const data = $(target).data()
    if (target.checked) {
      hideFormRegions(data.hide)
    } else {
      showFormRegions(data.hide)
    }
  })

  $('.checkbox-toggle-collapse').on('change', ({ target }) => {
    const data = $(target).data()
    const checked = $(target).is(':checked')
    $(data.collapse).toggleClass(
      'collapse',
      data.checkShows ? !checked : checked
    )
  })

  $('.volunteer-active-checkbox-changes').trigger('change')
  $('.checkbox-toggle-collapse').trigger('change')
}

const toggleOtherInput = (target) => {
  if (!target) return

  const checked = $(target).is(':checked')
  $('#volunteer_other_offer_desc').parent().toggle(checked)
}

const hideFormRegions = (hide) => {
  hide.forEach((cssClass) => $(`.${cssClass}`).hide())
}

const showFormRegions = (hide) => {
  hide.forEach((cssClass) => $('.' + cssClass).show())
}

const show_rejection = (target = '#volunteer_acceptance') => {
  if ($(target).val() === 'rejected') {
    return $('.volunteer_rejection_type, .volunteer_rejection_text').show()
  }
  $('.volunteer_rejection_type, .volunteer_rejection_text').hide()
}
