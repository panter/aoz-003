$(function() {
  $( document ).on('turbolinks:render, turbolinks:load', function() {
    show_rejection();

    $('#volunteer_state').on('change', function(){
      show_rejection();
    });

    $('.volunteer-active-checkbox-changes').bind('change', ({target}) => {
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
  console.log(hide);
  hide.forEach(cssClass => $(`.${cssClass}`).hide());
}

const showFormRegions = (hide) => {
  hide.forEach(cssClass => $('.' + cssClass).show());
}

const changeStateSelectToNonActiveVolunteer = ({remove}) => {
  const options = $('#volunteer_state');
  remove.forEach(value => {
    options.find(`[value="${value}"]`).show();
  });
}

const changeStateSelectToActiveVolunteer = ({remove, selected}) => {
  const options = $('#volunteer_state');
  remove.forEach(value => {
    console.log(options);
    options.find(`[value="${value}"]`).hide();
  });
  options.val(selected);
}

function show_rejection() {
  if($('#volunteer_state').val() == 'rejected') {
    $('.volunteer_rejection_type').show();
    $('.volunteer_rejection_text').show();
  } else {
    $('.volunteer_rejection_type').hide();
    $('.volunteer_rejection_text').hide();
  }
}
function newFunction() {
    return '#volunteer_state';
}

