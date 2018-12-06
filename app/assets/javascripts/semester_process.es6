$(() => {
  // Only run this on new_semester_process_path
  if (Routes.new_semester_process_path() !== window.location.pathname) { return }

  $('select.semester-selector').change(({ target }) => {
    window.location.href = `${window.location.origin}${Routes.new_semester_process_path({ semester: $(target).val() })}`
  })
})
