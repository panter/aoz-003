$(() => {
  const getFieldsLabel = ({id}) => ($('label[for="'+id+'"]'));

  const showFieldWithLabel = (field) => {
    $(field).show();
    getFieldsLabel(field).show();
  }

  const hideFieldWithLabel = (field) => {
    $(field).hide();
    getFieldsLabel(field).hide();
  }

  const getFormGroupInputs = ({subject, model}) => (
    $('.form-group.' + model + '_' + subject + ' input[type="checkbox"],.form-group.' + model + '_' + subject + ' input[type="radio"]')
  );

  const getInputCollection = ({model, subject}) => (
    subject.map((formGroup) => (
      getFormGroupInputs({model, subject: formGroup})[0]
    ))
  );

  const reduceInputCollectionChecked = (inputs) => (
    inputs.reduce((first, second) => (
      ( ((typeof first === 'boolean') ? first : first.checked) || second.checked )
    ))
  );

  const handleInputGroupChange = ({inputs, field}) => {
    inputs.forEach((input) => {
      $(input).bind('change', () => {
        if(reduceInputCollectionChecked(inputs)) {
          showFieldWithLabel(field);
        } else {
          hideFieldWithLabel(field);
        }
      });
    });
  }

  const showForCheckbox = ({field, subject, model}) => {
    getFormGroupInputs({subject, model}).bind('change', ({target: {checked}}) => {
      if(checked) {
        showFieldWithLabel(field)
      } else {
        hideFieldWithLabel(field)
      }
    });
  }

  const showForRadio = ({field, subject, model, value}) => {
    $('#' + model + '_' + subject + '_' + value).bind('change', ({target}) => {
      if(target.checked) {
        showFieldWithLabel(field);
        $(target).off('change');
        getFormGroupInputs({subject, model}).bind('change', ({rem_target}) => {
          hideFieldWithLabel(field);
          $(rem_target).off('change');
          showForRadio({field, data: {subject, model, value}});
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

  $('input.conditional-group[type="checkbox"]').each((key, field) => {
    const {value, model, subject} = $(field).data();
    const inputs = getInputCollection({model, subject});
    handleInputGroupChange({inputs, field});
  });
});


