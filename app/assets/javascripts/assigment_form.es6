function assigmentForm() {
  $('.assignments .print-assignment a, .assignments .download-assignment a').on('click', (event) => {
    event.preventDefault();
    event.stopPropagation();

    let newWindow = undefined;
    let href = $(event.currentTarget).attr('href');
    let target = $(event.currentTarget).attr('target')

    if (target === '_blank') {
      newWindow = window.open('', '_blank');
    }

    submitForm().then((data) => {
      if (target === '_blank') {
        newWindow.location = href;
      } else {
        Turbolinks.visit(href);
      }
    });
  });

  const submitForm = (callback) => {
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
