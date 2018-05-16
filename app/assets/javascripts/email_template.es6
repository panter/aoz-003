function addVarnames (varNames) {
  $('#template-variables li').remove();
  $('#template-variables').append(
    varNames.map(function (varName) {
      return $('<li>').addClass('list-group-item').html('%{' + varName + '}');
    })
  );
}
function toggleTemplateExample (varNames) {
  if (varNames.length < 1) {
    $('.instruction-default').hide();
    $('.instruction-hidden').show()
  } else {
    $('.instruction-default').show();
    $('.instruction-hidden').hide()
  }
}
function addTemplateStrings (subject, body) {
  if ($('form.edit_email_template').length) {
    return;
  }

  $("#email_template_subject").val(subject);
  $("#email_template_body").val(body);
}
function emailTemplate() {
  var kind = $("#email_template_kind").val();
  if (!kind) {
    return;
  }
  toggleTemplateExample(templateVarnames[kind]);
  addTemplateStrings(templateStrings[kind]['subject'], templateStrings[kind]['body']);
  $('#email_template_kind').change(function () {
    var newKind = $("#email_template_kind").val();
    var varNames = templateVarnames[newKind] || {} ;
    var strings = templateStrings[newKind] || {} ;
    addTemplateStrings(strings['subject'], strings['body']);
    addVarnames(varNames);
    toggleTemplateExample(varNames);
  });
}
