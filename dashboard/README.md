API
=======

```
GET /request-run/:browser/:platform/:test_name
```
* Requests a new test run, and returns a unique test_id.

```
GET /test/:test_id/node-status
```
* Get current node-status

```
PUT /test/:test_id/has-video/:has_video
```
* Updates value of has_video. This should be requested when video has become available to view. Valid values for has_video: [0,1]

```
PUT /test/:test_id/remote-info/:host/:port
```
* Updates value of host and rdp_port. Host should equal either IP or FQD of system running vm node.

```
PUT /test/:test_id/node-status/:node_status
```
* Updates value of node_status
* VALID_NODE_STATUS = ["queued", "waiting", "failed", "in_progress", "finished", "terminated"]

```
PUT /update-test-result/:test_id/:result
```
* Updates value of test result.

```
PUT /test/:test_id/log-entry/:level/:log_entry
```
* Create log entry

```
GET /status
```
* Get system status
