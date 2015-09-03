Template.navbar.helpers
  searchQuery: ->
    SessionAmplify.get 'search-query'
  activeFilters: ->
    filters = SessionAmplify.get('filter_by').length
    if filters == 0
      return false
    return filters
  displayFilter: ->
    SessionAmplify.get 'display_filter_by'
  displayFilterNavbar: ->
    SessionAmplify.get 'display_filter_navbar'

Template.navbar.events
  'click #filter_by_toggle': (e,t) ->
    parent = $('#filter_by_toggle').parent()
    if SessionAmplify.get 'display_filter_by'
      $('.filter_by').parent().slideUp 100, ->
        SessionAmplify.set 'display_filter_by', false
    else
      $('.filter_by').parent().slideDown 100, ->
        SessionAmplify.set 'display_filter_by', true
        $("html, body").animate scrollTop: '0'

  'click .navbar-brand': (e,t) ->
    SessionAmplify.set 'search-query', ''
  'submit form': (e,t) ->
    return false
  'click #clear_all_btn': ->
    if confirm('Are you sure?')
      Tests.remove {}
    return
  'keyup #search-field': (event) ->
    clearTimeout(window.search_timeout)
    window.search_timeout = setTimeout((->
      SessionAmplify.set 'search-query', event.currentTarget.value
      return
    ), 500)
    return
