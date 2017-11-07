$(() => $(document).on('turbolinks:render, turbolinks:load', () => {
  let debounceTimeout;
  $('.li-search-form .search-field').on('input', ({target: { value }}) => {
    if(value.length >= 2 ) {
      getSearchSuggest(value)
    }
  });
}));

const getSearchSuggest = debounce((value) => {
  const controller = window.location.href.split('/')[3].split('?')[0];
  $.getJSON(`/${controller}/search`, { search: value }, (result) => {
    console.log(result.clients);
  });
}, 100);

function debounce(func, wait, immediate) {
	var timeout;
	return function() {
		var context = this, args = arguments;
		var later = function() {
			timeout = null;
			if (!immediate) func.apply(context, args);
		};
		var callNow = immediate && !timeout;
		clearTimeout(timeout);
		timeout = setTimeout(later, wait);
		if (callNow) func.apply(context, args);
	};
}
