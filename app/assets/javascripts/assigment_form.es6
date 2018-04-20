function assigmentForm() {
  $('.assignments .download-assignment a').on('click', (event) => {
    let href = $(event.currentTarget).attr('href');
    submitForm().then((data) => {
      Turbolinks.visit(href);
    });
    return false;
  });

  const submitForm = () => {
    let form = $('form.edit_assignment');
    let formAction = form.attr('action');
    let valuesToSubmit = form.serialize();

    return new Promise((resolve, reject) => {
      $.ajax({
        type: 'POST',
        url: formAction,
        data: valuesToSubmit
      }).success((data) => {
        resolve(data);
      });
    });

    return false;
  }
}
