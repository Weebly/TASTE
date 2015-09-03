import requests

class taste:

  def __init__(self, host):
    self._host = host

  def request_run(self, options):
    payload = {
      'test_name': options['test_name'],
      'browser': options['browser'],
      'platform': options['platform'],
      'build_tag': '',
      'build_url': '',
      'branch': ''
    }

    if 'build_tag' in options:
      payload['build_tag'] = options['build_tag']
    if 'build_url' in options:
      payload['build_url'] = options['build_url']
    if 'branch' in options:
      payload['branch'] = options['branch']

    resp = requests.post('%s/request-run' % self._host, data=payload)
    self._application_name = resp.text
    return self._application_name

  def update_test_result(self, status): 
    if status:
      result = 'pass'
    else:
      result = 'fail'
    resp = requests.get('%s/update-test-result/%s/%s' % (self._host, self._application_name, result))
