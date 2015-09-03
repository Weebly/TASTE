MochaWeb?.testOnly ->

  describe "homepage", ->
    describe "navbar", ->
      it "should display one brand link", ->
        chai.assert $('nav a.navbar-brand').length == 1

      it "should have a search field", ->
        chai.assert $('nav input#search-field').length == 1

      describe "search field", ->
        it "should have a placeholder with text 'Search'", ->
          chai.assert $('nav input#search-field').attr('placeholder') == 'Search'

    describe "test index", ->
      it "should have a table to display test results", ->
        chai.assert $('.container-fluid table').length == 1

      it "should have a Session column", ->
        chai.assert $('table th:contains(Session)').length == 1

      it "should have an Environment column", ->
        chai.assert $('table th:contains(Environment)').length == 1

      it "should have an Build Tag column", ->
        chai.assert $('table th:contains(Build Tag)').length == 1

      it "should have an Result column", ->
        chai.assert $('table th:contains(Result)').length == 1

      it "should have an Start column", ->
        chai.assert $('table th:contains(Start)').length == 1

      it "should have an Run Time column", ->
        chai.assert $('table th:contains(Run Time)').length == 1

      it "should have an Node Status column", ->
        chai.assert $('table th:contains(Node Status)').length == 1

    describe "inserting a new test", ->
      before (done)->
        # remove existing tests
        Meteor.call 'removeTest', {}, (err,res)->
          if err
            console.log err
          console.log res

          # insert new test
          data = {}
          data.test_name = "integration test session"
          data.browser = "chrome"
          data.platform = "Windows 7"
          data.build_tag = "integration_test_build_tag"
          data.build_url = "integration_test_build_url"
          data.branch = "testing-new-branch-integration"
          data.is_test = true
          $.post '/request-run', data, (obj, status)->
            window.test_id = obj
            done()

      it "should add test as a row in test index table", ->
        chai.assert $('table tbody tr').length == 1

      it "should display test name in session column", ->
        chai.assert.equal $('table tbody tr td:nth-child(1) a').html(), 'integration test session'

      it "should display browser and platform in environment column with an icon for the platform.", ->
        chai.assert.equal $('table tbody tr td:nth-child(2)').html(), 'chrome <i class="fa fa-windows"></i> 7'

      it "should display build_tag text as hyperlink to build_url in build_tag column", ->
        chai.assert.equal $('table tbody tr td:nth-child(3) a').text(), 'integration_test_build_tag'

      it "should display a hyperlink in build_tag column with href equal to build_url", ->
        chai.assert.equal $('table tbody tr td:nth-child(3) a').attr('href'), 'integration_test_build_url'

      it "should display warning context class for result column", ->
        chai.assert $('table tbody tr td:nth-child(4)').hasClass('warning')

      it "should NOT display success context class for result column", ->
        chai.assert ! $('table tbody tr td:nth-child(4)').hasClass('success')

      it "should display start date/time in start column", ->
        chai.assert $('table tbody tr td:nth-child(5)').length > 0

      it "should NOT display run time initially", ->
        chai.assert $('table tbody tr td:nth-child(6)').text().length == 0

      it "should display node status as 'queued'", ->
        chai.assert.equal $('table tbody tr td:nth-child(7)').text().trim(), "queued"

      describe "updating remote info", ->
        before (done)->
          delete window.update_node_info_result
          $.ajax
            url: '/tests/' + window.test_id + '/remote-info/avm1.test.host/9001'
            type: 'PUT',
            success: (result)->
              window.update_node_info_result = JSON.parse(result)
              done()

        it "should display fa-desktop icon in session column", ->
          chai.assert $('table tbody tr td:nth-child(1) i.fa-desktop')

        it "should return a json object containing test_id", ->
          chai.assert window.update_node_info_result.test_id

        it "should return a json object containing host", ->
          chai.assert.equal window.update_node_info_result.host, "avm1.test.host"

        it "should return a json object containing rdp_port", ->
          chai.assert.equal window.update_node_info_result.rdp_port, "9001"

        describe "updating node-status", ->
          before (done)->
            delete window.update_status_result
            $.ajax
              url: '/tests/' + window.test_id + '/node-status/waiting'
              type: 'PUT',
              success: (result)->
                window.update_status_result = JSON.parse(result)
                setTimeout ->
                  done()
                , 250

          it "should return a json object containing test_id", ->
            chai.assert window.update_status_result.test_id

          it "should return a json object containing result: waiting", ->
            chai.assert.equal window.update_status_result.result, "waiting"

          it "should display node status as 'waiting'", ->
            chai.assert.equal $('table tbody tr td:nth-child(7)').text().trim(), "waiting"

          describe "updating has-video", ->
            before (done)->
              delete window.update_has_video_result
              $.ajax
                url: '/tests/' + window.test_id + '/has-video/1'
                type: 'PUT',
                success: (result)->
                  window.update_has_video_result = JSON.parse(result)
                  done()

            it "should return a json object containing test_id", ->
              chai.assert window.update_has_video_result.test_id

            it "should display glyphicon-facetime-video icon in session column", ->
              chai.assert $('table tbody tr td:nth-child(1) span.glyphicon-facetime-video')
