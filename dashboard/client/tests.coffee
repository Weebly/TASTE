Template.test_screencast.helpers
  currentTestId: ->
    Session.get 'viewing_test_id'
  videoFileHost: ->
    Session.get 'VIDEO_FILE_HOST_URL'
  has_video: ->
    return Tests.findOne(_id: Session.get('viewing_test_id')).has_video

Template.test_screencast.events
  'loadedmetadata video': (e,t) ->
    t.find('video').currentTime = Session.get 'video_time'

Template.test_screencast.rendered = ->

  Meteor.call 'getVideoFileHostUrl', (err, data) ->
    if err
      console.log 'SHOULD NOT HAPPEN'
    else
      Session.set 'VIDEO_FILE_HOST_URL', data
    return
  return

Template.test_view.helpers
  session: ->
    Tests.findOne(_id: Session.get('viewing_test_id')).session
  branch: ->
    Tests.findOne(_id: Session.get('viewing_test_id')).branch
  environment: ->
    Tests.findOne(_id: Session.get('viewing_test_id')).environment
  build_url: ->
    Tests.findOne(_id: Session.get('viewing_test_id')).build_url
  build_tag: ->
    Tests.findOne(_id: Session.get('viewing_test_id')).build_tag
  test_result: ->
    result = Tests.findOne(_id: Session.get('viewing_test_id')).result
    switch result
      when "pass" then "success"
      when "fail" then "danger"
      else "warning"
  result: ->
    Tests.findOne(_id: Session.get('viewing_test_id')).result

Template.testindex.events
  'click .clear_filter_link': (e,t)->
    e.preventDefault()
    SessionAmplify.set 'search-query',''

Template.testindex.helpers
  activeFilter: ->
    Boolean(SessionAmplify.get('search-query').length)
  query: ->
    SessionAmplify.get('search-query')
  tests: ->
    query = new RegExp(SessionAmplify.get('search-query'), 'i')
    filter_by = SessionAmplify.get('filter_by')
    filter_or = []
    _.each filter_by, (field)->
      obj = {}
      obj[field.filter_by.toLowerCase()] = new RegExp(field.filter_value, 'i')
      filter_or.push obj

    if filter_or.length > 0
      find_query = {
        $and: [{
          $and: filter_or
        },
        {
          $or: [
            { '_id': query }
            { 'session': query }
            { 'environment': query }
            { 'tags': query }
            { 'build_tag': query }
            { 'build_url': query }
            { 'branch': query }
            { 'node_status': query }
          ]
        }]
      }
    else
      find_query = {
        $or: [
          { '_id': query }
          { 'session': query }
          { 'environment': query }
          { 'tags': query }
          { 'build_tag': query }
          { 'build_url': query }
          { 'branch': query }
          { 'node_status': query }
        ]
      }
    results = Tests.find(
      find_query,
      sort: createdAt: -1
      limit: 100)
    results

Template.test.helpers
  createdAt: ->
    moment(@createdAt).format 'MM/DD/YYYY @ h:mm:ss a'
  isComplete: ->
    @node_status == 'terminated'
  videoFileHost: ->
    Session.get 'VIDEO_FILE_HOST_URL'
  environment: ->
    env = @environment.split(':')
    browser = env[0].trim()
    platform = env[1].trim().split(' ')[0].toLowerCase()
    platform_version = env[1].trim().split(' ')[1]
    browser + ' <i class="fa fa-' + platform + '"></i> ' + platform_version
  result: ->
    switch @result
      when "pass" then "success"
      when "fail" then "danger"
      else "warning"
  run_time: ->
    if typeof @endDate != 'undefined'
      moment.duration(moment(@endDate).diff(moment(@createdAt))).humanize()
  break_point: ->
    @node_status == "break_point"

Template.test.events
  'click .terminate-session-btn': (e,t)->
    e.preventDefault()
    Meteor.call 'finishTest', @_id, (err,res)->
      if err
        console.log err
      console.log 'Request to terminate session sent.'
  'click .filter-build-tag-btn': (e,t)->
    e.preventDefault()
    if @build_tag
      current_filters = SessionAmplify.get 'filter_by'
      current_filters.push
        filter_by: 'build_tag'
        filter_value: @build_tag
      SessionAmplify.set 'filter_by', current_filters
  'click .filter-node-status-btn': (e,t)->
    e.preventDefault()
    if @node_status
      current_filters = SessionAmplify.get 'filter_by'
      current_filters.push
        filter_by: 'node_status'
        filter_value: @node_status
      SessionAmplify.set 'filter_by', current_filters

Template.filter_by.events
  'submit #filter_by_form': (e,t)->
    e.preventDefault()
    filter_by = t.find('select[name=filter_by]').value
    filter_value = t.find('input[name=filter_value]').value.trim()
    if filter_by != 'Filter by' and filter_value.length > 0
      current_filters = SessionAmplify.get 'filter_by'
      current_filters.push
        filter_by: filter_by
        filter_value: filter_value
      SessionAmplify.set('filter_by', current_filters)
      $('select[name=filter_by] option:first-child').prop('selected',true)
      $('input[name=filter_value]').val('')

Template.filter_by.helpers
  hideFilter: ->
    !SessionAmplify.get 'display_filter_by'
  current_filters: ->
    SessionAmplify.get 'filter_by'

Template.filter.events
  'click .dropdown-toggle': (e,t)->
    e.preventDefault()
    current_filters = SessionAmplify.get 'filter_by'
    current_filters.splice(@index, 1)
    SessionAmplify.set('filter_by', current_filters)

Template.registerHelper 'addIndex', (all)->
  return _.map all, (val, index)->
    return index: index, value: val
