/**
 * Autocomplete init for search autocompletes
 *
 * https://github.com/devbridge/jQuery-Autocomplete
 */

$(() => {
  const findSearchParam = (param) => {
    const qParam = window.location.search
      .slice(1)
      .split('&')
      .map((part) => part.split('='))
      .find((parts) => decodeURIComponent(parts[0]) === param)
    if (qParam && qParam.length === 2) {
      return decodeURIComponent(qParam[1]).split('+').join(' ')
    }
    return null
  }

  $('.search-field-autocomplete').each((_index, field) => {
    const searchField = $(field)
    const fieldName = searchField.attr('name')

    const { autocomplete, param } = searchField.data()
    const delimitor = autocomplete.includes('?') ? '&' : '?'
    const searchParam = param || fieldName
    const baseUrl = `${autocomplete}${delimitor}${searchParam}=`

    searchField.devbridgeAutocomplete({
      minChars: 2,
      groupBy: 'category',
      lookup: (query, done) => {
        $.get(baseUrl + query, (suggestions) => done({ suggestions }), 'json')
      },
      onSelect: ({ data, value }) => {
        const searchValue = findSearchParam(fieldName)
        if (searchValue !== value) {
          searchField.val(data.search)
          searchField.closest('form').trigger('submit')
        }
      },
    })
  })
})
