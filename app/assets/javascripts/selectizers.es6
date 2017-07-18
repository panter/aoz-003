$(() => {
  $('#relatives select[name$="[relation]"]').selectize();
  $('.add-relation-button').bind('click', ({target}) => {
    console.log(target);
    setTimeout(() => {
      $('#relatives select[name$="[relation]"]').selectize();
    }, 0);
  });
});
