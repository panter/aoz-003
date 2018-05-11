$(() => {
  let formFilter = 'form:not([method="get"], .form-ignore-changes)';
  let formSubmitting = false, formData = $(formFilter).serialize();

  $(window).on('beforeunload', (event) => {
    if (!formSubmitting && ($('.has-error').length || formData !== $(formFilter).serialize())) {
      event.returnValue = "Möchten Sie Ihre ungespeicherten Änderungen verwerfen?";
      return event.returnValue;
    }
  });

  $(document).on('submit', 'form', () => {
    formSubmitting = true;
  });
});
