$(() => $(document).on('turbolinks:render, turbolinks:load', () => {
  const isBoolean = (value) => value === true || value === false;
  const getData = node => $(node).data();
  const offChange = (node) => $(node).off('change');
  const bindChange = (node, cb) => $(node).bind('change', cb);
  const boolOrChecked = (element) => (isBoolean(element)) ? element : element.checked;
  const containsChecked = (inputs) => inputs.reduce((first, second) => boolOrChecked(first) || second.checked);
  const nodeArray = (selector) => $.makeArray($(selector));
  const show = node => $(node).show() && true;
  const hide = node => $(node).hide() && true;
  const showFieldWithLabel = (field) => show(field) && show($(`label[for="${field.id}"]`));
  const hideFieldWithLabel = (field) => hide(field) && hide($(`label[for="${field.id}"]`));
  const showWithRow = ({field, row}) => show(row) && showFieldWithLabel(field);
  const hideWithRow = ({field, row}) => hide(row) && hideFieldWithLabel(field);
  const showRowIfChecked = (input, elements) => input.checked && showWithRow(elements);

  const groupInputSelector = (type, {model, attribute}) => `.form-group.${model}_${attribute} input[type="${type}"]`;
  const getGroupInputs = (data) => nodeArray(['radio', 'checkbox'].map(type => groupInputSelector(type, data)).join(','));
  const getInputCollection = ({model, attribute}) => attribute.map(attribute => getGroupInputs({model, attribute})[0]);

  const handleInputGroupChange = ({inputs, field}) => {
    const row = $(field).parents('.row')[0];
    hide(row);
    inputs.forEach((input) => {
      showRowIfChecked(input, {field, row});
      bindChange(input, () =>
        (containsChecked(inputs)) ? showRowIfChecked(input, {field, row}) : hideWithRow({field, row})
      );
    });
  }

  const showFieldIfChecked = (field, input) => input && (input.checked) ? showFieldWithLabel(field) : hideFieldWithLabel(field);
  const handleSingleCheckbox = ({field, model, attribute}) => getGroupInputs({model, attribute}).forEach(
    (input) => {
      showFieldIfChecked(field, input);
      bindChange(input, () => showFieldIfChecked(field, input) || hideFieldWithLabel(field));
  });


  const hideFromRadio = ({field, model, attribute, value}) => getGroupInputs({model, attribute}).forEach(
    (input) => bindChange(input, ({target}) => {
      hideFieldWithLabel(field);
      offChange(target);
      handleRadioGroup({field, model, attribute, value});
  }));

  const showFromRadio = ({field, input, model, attribute, value}) => (
    showFieldIfChecked(field, input) && offChange(input) && hideFromRadio({field, model, attribute, value})
  );

  const handleRadioGroup = ({field, model, attribute, value}) => {
    const input = $(`input#${model}_${attribute}_${value}`)[0];
    showFromRadio({field, input, model, attribute, value});
    bindChange(input, () => showFromRadio({field, input, model, attribute, value}));
  }

  nodeArray('.conditional-field').forEach((field) => {
    const data = getData(field);
    (data.value) ? handleRadioGroup({field, ...data}) : handleSingleCheckbox({field, ...data});
  });

  nodeArray('input.conditional-group[type="checkbox"]').forEach((field) => {
    handleInputGroupChange({inputs: getInputCollection(getData(field)), field});
  });
}));
