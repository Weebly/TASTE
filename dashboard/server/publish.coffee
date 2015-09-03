Meteor.publish 'tests', (keyword, filter_by) ->
  query = new RegExp(keyword, 'i')
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

Meteor.publish 'test', (test_id) ->
  Tests.find {_id: test_id}
