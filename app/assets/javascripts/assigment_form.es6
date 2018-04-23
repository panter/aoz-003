function assigmentForm() {
  $('.autosave-button a').on('click', (event) => {
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
    let form = $('form.simple_form');
    let formAction = form.attr('action');
    let valuesToSubmit = form.serialize();

    console.log(formAction);

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
