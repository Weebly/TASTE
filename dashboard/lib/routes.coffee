Router.configure
  layoutTemplate: 'AppLayout'

Router.route '/',
  name: 'index'
  template: 'testindex'
  onBeforeAction: ->
    SessionAmplify.set 'display_filter_navbar', true
    @next()
  subscriptions: ->
    [
      Meteor.subscribe 'tests', SessionAmplify.get('search-query'), SessionAmplify.get('filter_by')
    ]

Router.route '/tests/:test_id/:video_time?',
  template: 'test_view'
  onBeforeAction: ->
    SessionAmplify.set 'display_filter_navbar', false
    @next()
  waitOn: ->
    [
      Session.set 'video_time', '0'
      if @params.video_time
        Session.set 'video_time', @params.video_time
      Session.set 'viewing_test_id', @params.test_id
      Meteor.subscribe 'test', this.params.test_id
    ]
