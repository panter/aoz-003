$(function() {
  $( document ).on('turbolinks:render, turbolinks:load', function() {
    $('input:radio[name="group_offer[volunteer_state]"]').on('change', ({target}) => {
      populate_dropdowns(target);
    });

    $(document).on('cocoon:after-insert', function(e, insertedItem) {
      populate_dropdowns('input:radio[name="group_offer[volunteer_state]"]:checked');
    });
  });
});

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
