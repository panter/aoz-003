function groupOfferForm() {
  // scroll to the volunteers partial when sorting / paginating
  $('#add-volunteers').find('a.sort_link, a.page-link').each((i, link) => {
    link.hash = '#add-volunteers';
  });

  $('.group_offer_offer_type input').on('change', toggleGroupOfferLocationFields);
  toggleGroupOfferLocationFields();
}

function toggleGroupOfferLocationFields() {
  var internal = $('#group_offer_offer_type_internal_offer').is(':checked');
  $('.group-offer-internal-fields').toggle(internal);
  $('.group-offer-external-fields').toggle(!internal);
}
