$(() => {
  const getFieldsLabel = (field) => ($('label[for="'+field.id+'"]'));
  const getFormGroupInputs = (data) => (
    $('.form-group.' + data.model + '_' + data.subject + ' input')
  );
  const showForCheckbox = ({field, data}) => {
    getFormGroupInputs(data).bind('change', ({target}) => {
      if(target.checked) {
        $(field).show();
        getFieldsLabel(field).show();
      } else {
        $(field).hide();
        getFieldsLabel(field).hide();
      }
    });
  }
  const showForRadio = ({field, data}) => {
    $('#' + data.model + '_' + data.subject + '_' + data.value).bind('change', ({target}) => {
      if(target.checked) {
        $(field).show();
        getFieldsLabel(field).show();
        $(target).off('change');
        getFormGroupInputs(data).bind('change', ({rem_target}) => {
          $(field).hide();
          getFieldsLabel(field).hide();
          $(rem_target).off('change');
          showForRadio({field, data});
        });
      }
    });
  }

  $('.conditional-field').each((key, field) => {
    const data = $(field).data();
    if(data.value) {
      return showForRadio({field, data});
    }
    showForCheckbox({field, data});
  });
});


