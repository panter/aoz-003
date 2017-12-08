$(function() {
  $( document ).on('turbolinks:render, turbolinks:load', function() {
    show_rejection();
    show_experience();

    $('#volunteer_acceptance_rejected').on('change', ({target}) => {
      show_rejection(target);
    });

    $('#volunteer_experience').on('change', ({target}) => {
      show_experience(target);
    });

    $('.volunteer-active-checkbox-changes').on('change', ({target}) => {
      const data = $(target).data();
      if(target.checked) {
        changeStateSelectToActiveVolunteer(data.state);
        hideFormRegions(data.hide);
      } else {
        changeStateSelectToNonActiveVolunteer(data.state);
        showFormRegions(data.hide);
      }
    });
  });
});

const hideFormRegions = (hide) => {
  hide.forEach(cssClass => $(`.${cssClass}`).hide());
}

const showFormRegions = (hide) => {
  hide.forEach(cssClass => $('.' + cssClass).show());
}

const changeStateSelectToNonActiveVolunteer = ({remove}) => {
  const options = $('#volunteer_state');
  remove.forEach(value => options.find(`[value="${value}"]`).show());
}

const changeStateSelectToActiveVolunteer = ({remove, selected}) => {
  const options = $('#volunteer_state');
  remove.forEach(value => options.find(`[value="${value}"]`).hide());
  options.val(selected);
}

const show_rejection = (target) => {
  if($(target).val() == 'rejected') {
    return $('.volunteer_rejection_type, .volunteer_rejection_text').show();
  }
  $('.volunteer_rejection_type, .volunteer_rejection_text').hide();
}

const show_experience = (target) => {
  $('.volunteer_volunteer_experience_desc').toggle();
}
