function groupOfferForm() {
  if (window.location.href.indexOf('new') > 0) {
    $('#add_volunteers').prop('disabled', true).attr('disabled', true);
  } else {
    $('#add_volunteers_text').hide();
  }
  if ($('input:radio[name="group_offer[volunteer_state]"]').is(':checked')){
    $('input:radio[name="group_offer[volunteer_state]"]').attr('disabled', true);
  }

  $('input:radio[name="group_offer[volunteer_state]"]').on('change', ({target}) => {
    $('#add_volunteers').prop('disabled', false).attr('disabled', false);
    $('#add_volunteers_text').hide();
    populate_dropdowns(target);
  });

  $(document).on('cocoon:after-insert', function(e, insertedItem) {
    populate_dropdowns('input:radio[name="group_offer[volunteer_state]"]:checked');
  });
}

const populate_dropdowns = (target) => {
  var selectInternals = $('.new-group-offer-volunteer-collection');
  var items=[];
  if($(target).val() == 'internal_volunteer') {
    items = JSON.parse($('input[name=internals]').val());
  } else {
    items = JSON.parse($('input[name=externals]').val());
  }

  selectInternals.empty();
  for (var i = 0; i < items.length; i++) {
    var opt = document.createElement('option');
    opt.value = items[i].id;
    opt.innerHTML = items[i].value;
    selectInternals.append(opt);
  }
}
