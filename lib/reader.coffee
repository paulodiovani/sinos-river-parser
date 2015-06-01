fs      = require('fs')
url     = require('url')
http    = require('http')
through = require('through')
phantom = require('phantom')

module.exports = class Reader
  messages =
    noSourceError: 'a valid source must be provided'
    httpStatusError: 'http status'

  source: null
  sourceType: null

  constructor: (@source) ->
    return unless @source
    switch
      when @_httpOptions(@source).protocol in ['http:', 'https:']
        @sourceType = 'url'
      when fs.existsSync @source
        @sourceType = 'file'
      else
        @source = null

  getStream: (callback = ->) ->
    switch @sourceType
      when 'file'
        @getFileStream @source, callback
      when 'url'
        @getUrlStream @source, callback
      else
        callback new Error(messages.noSourceError)
    return

  getFileStream: (source, callback = ->) ->
    callback null, fs.createReadStream(source)
    return

  getUrlStream: (source, callback = ->) ->
    tr = through (data) ->
      @emit 'data', data

    phantom.create (ph) ->
      ph.createPage (page) ->
        page.set 'onResourceReceived', (res) ->
          if res.stage is 'end' and res.status isnt 200
            err = new Error "#{messages.httpStatusError} #{res.status}:
              #{http.STATUS_CODES[res.status]}"
            callback err

        page.open source, (status) ->
          return if status isnt 'success'
          callback null, tr

          page.evaluate (-> document.body.innerHTML), (result) ->
            tr.end result
            ph.exit()
    ,
      parameters:
        'ignore-ssl-errors': 'yes'

  _httpOptions: (options) ->
    options = url.parse options if typeof options is 'string'
    options
