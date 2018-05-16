function assigmentForm() {
  $('.autosave-button a').on('click', (event) => {
    event.preventDefault();
    event.stopPropagation();

    let newWindow = window;
    let href = $(event.currentTarget).attr('href');
    let target = $(event.currentTarget).attr('target')

    if (target === '_blank') {
      newWindow = window.open('', '_blank');
    }

    submitForm().then((data) => {
      newWindow.location.href = href;
    });
  });

  const submitForm = (callback) => {
    let form = $('form.simple_form');
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
