@Tests = new Mongo.Collection("tests")

@Schemas = {}

VALID_NODE_STATUS = [
  "queued"
  "waiting"
  "failed"
  "in_progress"
  "finished"
  "terminated"
  "break_point"
]

VALID_RESULT = ["pass", "fail"]

@Schemas.Test = new SimpleSchema
  session:
    type: String
    index: 1
  createdAt:
    type: Date
  last_command:
    type: Date
    optional: true
  endDate:
    type: Date
    optional: true
  environment:
    type: String
    index: 1
  node_status:
    type: String
    allowedValues: VALID_NODE_STATUS
    index: 1
  rdp_port:
    type: Number
    optional: true
  host:
    type: String
    optional: true
  result:
    type: String
    optional: true
    allowedValues: VALID_RESULT
    index: 1
  build_tag:
    type: String
    optional: true
    index: 1
  build_url:
    type: String
    optional: true
    index: 1
  branch:
    type: String
    optional: true
    index: 1
  has_video:
    type: Boolean
    optional: true
  has_errors:
    type: Boolean
    optional: true

@Tests.attachSchema @Schemas.Test
