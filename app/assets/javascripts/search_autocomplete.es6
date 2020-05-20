/**
 * Autocomplete init for search autocompletes
 *
 * https://github.com/devbridge/jQuery-Autocomplete
 */

$(() => {
  $('.search-field-autocomplete').each((_index, field) => {
    const searchField = $(field)

    const { autocomplete } = searchField.data()
    const delimitor = autocomplete.includes('?') ? '&' : '?'
    const baseUrl = `${autocomplete}${delimitor}term=`

    searchField.devbridgeAutocomplete({
      minChars: 2,
      groupBy: 'category',
      lookup: (query, done) => {
        $.get(baseUrl + query, (suggestions) => done({ suggestions }), 'json')
      },
      onSelect: () => searchField.closest('form').trigger('submit'),
    })
  })
})
