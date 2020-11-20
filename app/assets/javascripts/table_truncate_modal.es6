function truncateModal() {
  $('#truncate-modal').on('show.bs.modal', ({ relatedTarget, target }) => {
    const { title, fulltext } = relatedTarget.dataset
    const modal = $(target)
    modal.find('.modal-title').html(title)
    modal.find('.modal-body').html(fulltext)
  })
}
