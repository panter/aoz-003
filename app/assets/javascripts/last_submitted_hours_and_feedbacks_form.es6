function lastSubmittedHoursAndFeedbacksForm() {
  let $form = $('.last-submitted-hours-and-feedbacks form');

  if ($form.length) {
    restoreForm($form);

    $('.last-submitted-hours-and-feedbacks .submit-button').on('click', ({target}) => {
      clearFormData($form);
      $form.submit();
      return false
    });

    $(window).on('beforeunload', (event) => {
      storeFormData($form);
    });
  }
}

const storeFormData = (form) => {
  let arrayOfValues = form.serializeArray();
  form.find('input:checkbox').each(function() {
    arrayOfValues = arrayOfValues.filter(object => object.name != this.name);
    arrayOfValues.push({ name: this.name, value: this.checked });
  });
  let stringValues = JSON.stringify(arrayOfValues);
  let name = cookieNameFor(form);

  Cookies.set(name, stringValues, { expires: 7, path: '' });
}

const restoreForm = (form) => {
  let name = cookieNameFor(form);
  let formValues = Cookies.get(name);

  if (formValues) {
    formValues = JSON.parse(formValues);
    for (var i = 0; i < formValues.length; i++) {
      let name = formValues[i].name;
      let value = formValues[i].value;
      if ($("input[name='" + name + "']").is(':checkbox')) {
        $("input[name='" + name + "']").attr('checked', (value === true));
        $("input[name='" + name + "']").val((value === true ? 1 : ''));
        $("input[name='" + name + "']").trigger('change');
      } else {
        $("input[name='" + name + "'], select[name='" + name + "']").val(value);
      }
    }
  }
}

const clearFormData = (form) => {
  let today = new Date();
  let expired = new Date(today.getTime() - 24 * 3600 * 1000);
  let name = cookieNameFor(form);

  Cookies.remove(name);
}

const cookieNameFor = (form) => {
  return form.attr('id') + '_form_values'
}
