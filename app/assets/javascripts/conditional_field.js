'use strict';

$(function () {
  var getFieldsLabel = function getFieldsLabel(field) {
    return $('label[for="' + field.id + '"]');
  };

  var showFieldWithLabel = function showFieldWithLabel(field) {
    $(field).show();
    getFieldsLabel(field).show();
  };

  var hideFieldWithLabel = function hideFieldWithLabel(field) {
    $(field).hide();
    getFieldsLabel(field).hide();
  };

  var getFormGroupInputs = function getFormGroupInputs(_ref) {
    var subject = _ref.subject,
        model = _ref.model;
    return $('.form-group.' + model + '_' + subject + ' input[type="checkbox"],.form-group.' + model + '_' + subject + ' input[type="radio"]');
  };

  var getInputCollection = function getInputCollection(_ref2) {
    var model = _ref2.model,
        subject = _ref2.subject;
    return subject.map(function (formGroup) {
      return getFormGroupInputs({ model: model, subject: formGroup })[0];
    });
  };

  var reduceInputCollectionChecked = function reduceInputCollectionChecked(inputs) {
    return inputs.reduce(function (first, second) {
      return (typeof first === 'boolean' ? first : first.checked) || second.checked;
    });
  };

  var handleInputGroupChange = function handleInputGroupChange(_ref3) {
    var inputs = _ref3.inputs,
        field = _ref3.field;

    inputs.forEach(function (input) {
      if (reduceInputCollectionChecked(inputs)) {
        showFieldWithLabel(field);
      }
      $(input).bind('change', function () {
        if (reduceInputCollectionChecked(inputs)) {
          showFieldWithLabel(field);
        } else {
          hideFieldWithLabel(field);
        }
      });
    });
  };

  var showForCheckbox = function showForCheckbox(_ref4) {
    var field = _ref4.field,
        subject = _ref4.subject,
        model = _ref4.model;


    getFormGroupInputs({ subject: subject, model: model }).each(function(key, input) {
      if (input.checked) {
        showFieldWithLabel(field);
      }
      $(input).bind('change', function (_ref5) {
        var checked = _ref5.target.checked;

        if (checked) {
          showFieldWithLabel(field);
        } else {
          hideFieldWithLabel(field);
        }
      });
    });
  };

  var showForRadio = function showForRadio(_ref6) {
    var field = _ref6.field,
        subject = _ref6.subject,
        model = _ref6.model,
        value = _ref6.value;

    $('#' + model + '_' + subject + '_' + value).each(function(key, input) {
      if(input.checked) {
        showFieldWithLabel(field);
      }
      $(input).bind('change', function (_ref7) {
        var target = _ref7.target;

        if (target.checked) {
          showFieldWithLabel(field);
          $(target).off('change');
          getFormGroupInputs({ subject: subject, model: model }).bind('change', function (_ref8) {
            var rem_target = _ref8.rem_target;

            hideFieldWithLabel(field);
            $(rem_target).off('change');
            showForRadio({ field: field, data: { subject: subject, model: model, value: value } });
          });
        }
      });
    });
  };

  $('.conditional-field').each(function (key, field) {
    var _$$data = $(field).data(),
        subject = _$$data.subject,
        value = _$$data.value,
        model = _$$data.model;

    if (value) {
      return showForRadio({ field: field, subject: subject, value: value, model: model });
    }
    showForCheckbox({ field: field, subject: subject, model: model });
  });

  $('input.conditional-group[type="checkbox"]').each(function (key, field) {
    var _$$data2 = $(field).data(),
        value = _$$data2.value,
        model = _$$data2.model,
        subject = _$$data2.subject;

    var inputs = getInputCollection({ model: model, subject: subject });
    handleInputGroupChange({ inputs: inputs, field: field });
  });
});
