$(function() {
  $( document ).on('turbolinks:render, turbolinks:load', function() {
    show_rejection();

    $('#volunteer_state').on('change', function(){
      show_rejection();
    });
  });
});

function show_rejection() {
  if($('#volunteer_state').val() == 'rejected') {
    $('.volunteer_rejection_type').show();
    $('.volunteer_rejection_text').show();
  } else {
    $('.volunteer_rejection_type').hide();
    $('.volunteer_rejection_text').hide();
  }
}
