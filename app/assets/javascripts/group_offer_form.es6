function groupOfferForm() {
  // scroll to the volunteers partial when sorting / paginating
  $('#add-volunteers').find('a.sort_link, a.page-link').each((i, link) => {
    link.hash = '#add-volunteers';
  });
}
