function truncateModal() {
  $('#truncate-modal').on('show.bs.modal', function ({relatedTarget, target}) {
    const {title, fullText} = $(event.relatedTarget).data();
    $(target).find('.modal-title').html(title);
    $(target).find('.modal-body').html(fullText);
  });
}
