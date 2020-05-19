function clientForm() {
  $('.reserve-client-action-cell').on('click', ({ target }) => {
    const cell = $(target).closest('td')
    const data = cell.data()
    const clientId = data.clientId || data.client_id
    $.ajax({
      url: `/clients/${clientId}/reserve`,
      type: 'PUT',
    }).done(({ user_name, btn_text }) => {
      cell.find('button, span').remove()
      if (user_name) {
        cell.append($(`<span>${user_name}</span>`))
        cell.append($(`<button class="btn btn-default">${btn_text}</button>`))
      } else {
        cell.append($(`<button class="btn btn-default">${btn_text}</button>`))
      }
    })
  })
}
