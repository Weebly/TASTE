Meteor.startup ->
  celery = Meteor.npmRequire 'node-celery'
  try
    @Client = celery.createClient
      CELERY_BROKER_URL: process.env['CELERY_BROKER_URL']
  catch err
    Meteor.Error "cannot-connect", "An exception occurred trying to connect to rabbitmq: " + err.message
    @response.end test_run

  @Client.on 'error', (err)->
    Meteor.Error "client-error", "Celery client error: " + err

Router.route '/tests/:test_id/has-video/:has_video', where: 'server'
  .put ->
    Tests.update @params.test_id,
      $set: has_video: @params.has_video == "1"
    @response.end JSON.stringify
      'test_id': @params.test_id
      'has_video': @params.has_video == "1"

Router.route '/tests/:test_id/remote-info/:host/:port', where: 'server'
  .put ->
    Tests.update @params.test_id,
      $set:
        host: @params.host
        rdp_port: @params.port
    @response.end JSON.stringify
      'test_id': @params.test_id
      'host': @params.host
      'rdp_port': @params.port

Router.route '/tests/:test_id/node-status/:node_status', where: 'server'
  .put ->
    if @params.node_status == "terminated"
      Tests.update @params.test_id,
        $set:
          node_status: @params.node_status
          endDate: new Date()
    else
      Tests.update @params.test_id,
        $set: node_status: @params.node_status
    @response.end JSON.stringify
      'test_id': @params.test_id
      'result': @params.node_status

Router.route '/update-test-result/:test_id/:result', where: 'server'
  .get ->
    doc =
      result: @params.result
    Tests.update @params.test_id,
      $set: doc
    , (err,res)->
      if err
        console.log err
    @response.end JSON.stringify
      'test_id': @params.test_id
      'result': @params.result
      'doc': doc

Router.route '/status', where: 'server'
  .get ->
    @response.end 'up'

Router.route '/request-run', where: 'server'
  .post ->
    test_name = @request.body.test_name
    browser = @request.body.browser
    platform = @request.body.platform
    build_tag = ""
    build_url = ""
    branch = ""
    custom_dns = false

    if typeof @request.body.build_tag != 'undefined'
      build_tag = @request.body.build_tag
    if typeof @request.body.build_url != 'undefined'
      build_url = @request.body.build_url
    if typeof @request.body.branch != 'undefined'
      branch = @request.body.branch
    if typeof @request.body.custom_dns != 'undefined'
      custom_dns = @request.body.custom_dns

    test_run = Tests.insert
      session: test_name
      environment: browser.toLowerCase() + " : " + platform
      build_tag: build_tag
      build_url: build_url
      branch: branch
      createdAt: new Date()
      node_status: 'queued'

    # check if this was just a test(abort if so)
    if @request.body.is_test
      @response.end test_run
      return

    parameters = [test_run, browser, platform]

    if custom_dns
      parameters.push custom_dns

    Client.call 'tasks.start_node', parameters, (res)->
      console.log res

    @response.end test_run
