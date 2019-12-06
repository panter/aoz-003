function clientForm() {
  $('.reserve-client-action-cell').on('click', ({ target }) => {
    const cell = $(target).closest('td')
    console.log(cell)
    const { clientId } = cell.data()
    $.ajax({
      url: `/clients/${clientId}/reserve`,
      type: 'PUT',

    }).done(({user_name, btn_text}) => {
      if (user_name) {
        cell.find('button').remove()
        cell.append($(`<span>${user_name}</span>`))
        cell.append($(`<button class="btn btn-default">${btn_text}</button>`))
      } else {
        cell.find('span').remove()
        cell.find('button').remove()
        cell.append($(`<button class="btn btn-default">${btn_text}</button>`))
      }
    }).fail(error => {
      console.log(error)
    })
  });
}
