$(function() {
  function initSelectize() {
    $('.selectize').selectize({
      create: true,
      sortField: 'text'
    });
  }

  $("#relatives").on("cocoon:after-insert", function() {
    initSelectize();
  });

  $( document ).on('turbolinks:render, turbolinks:load', function() {
    initSelectize();
  });
});
