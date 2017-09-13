$(function() {
  $( document ).on('turbolinks:render, turbolinks:load', function() {
    show_rejection();

    $('#volunteer_state').on('change', function(){
      show_rejection();
    });

    const store = {
      stateOptions: $('#volunteer_state')
    }

    $('#volunteer_external').bind('change', ({target}) => {
      if(target.checked) {
        removeNonExternalStates(store.stateOptions);
      } else {
        addStateOptionsBack(store.stateOptions);
      }
    });
  });
});

const addStateOptionsBack = (options) => {
  options.find('[value="contacted"]').show();
  options.find('[value="resigned"]').show();
  options.find('[value="inactive"]').show();
}

const removeNonExternalStates = (options) => {
  options.find('[value="contacted"]').hide();
  options.find('[value="resigned"]').hide();
  options.find('[value="inactive"]').hide();
  options.val('active');
}

function show_rejection() {
  if($('#volunteer_state').val() == 'rejected') {
    $('.volunteer_rejection_type').show();
    $('.volunteer_rejection_text').show();
  } else {
    $('.volunteer_rejection_type').hide();
    $('.volunteer_rejection_text').hide();
  }
}
function newFunction() {
    return '#volunteer_state';
}

