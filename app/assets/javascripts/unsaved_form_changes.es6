$(() => {
  let formSubmitting = false, formData = $('form').serialize();

  $(window).on('beforeunload', (event) => {
    if (!formSubmitting && ($('.has-error').length || formData !== $('form').serialize())) {
      event.returnValue = "Möchten Sie Ihre ungespeicherten Änderungen verwerfen?";
      return event.returnValue;
    }
  });

  $(document).on('submit', 'form', () => {
    formSubmitting = true;
  });
});
