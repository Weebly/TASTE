Meteor.methods
  getVideoFileHostUrl: ->
    process.env.VIDEO_FILE_HOST

  removeTest: (selector)->
    Tests.remove(selector)

  finishTest: (test_id)->
    req = process.env['ETCD_HOST'] + '/v2/keys/taste/' + test_id + '/status?value=finished'
    HTTP.put req, (err,res)->
      if err
        console.log err
      else
        Tests.update test_id, $set: node_status: 'finished'
      console.log res
    return
