$(function() {
  show_rejection();

  $('#volunteer_state').change(function(){
    show_rejection();
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
