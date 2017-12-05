function truncateModal() {
  $('#truncate-modal')
    .on('show.bs.modal', function (event) {
      var button = $(event.relatedTarget)
      var fullText = button
        .data()
        .fulltext
      var title = button
        .data()
        .title
      var modal = $(this)
      modal
        .find('.modal-title')
        .html(title)
      modal
        .find('.modal-body')
        .html(fullText)
    });
}
