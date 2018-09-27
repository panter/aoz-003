$(() => {
  $('.api-button').click(({target}) => {
    const { method, url, template } = $(target).data()
    const tableCell = target.closest('td')

    $.ajax({ method, url, dataType: 'json' })
      .done(data => {
        if (data.errors) {
          $(tableCell).append(`<p class="text-danger">Es gab einen Fehler: ${data.errors.join('; ')}</p>`)
        } else {
          const compiled = _.template(template, { 'variable': 'data', 'imports': { 'data': data } })
          target.remove()
          $(tableCell).append(compiled(data))
        }
      })
  })
})