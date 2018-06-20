function lastSubmittedHoursAndFeedbacksForm() {
  $('.assignments.last-submitted-hours-and-feedbacks .submit-button').on('click', ({target}) => {
    $('.assignments.last-submitted-hours-and-feedbacks form.edit_assignment').submit();
    return false
  });
}
