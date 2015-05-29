fs = require('fs')

module.exports = class Reader
  messages =
    noSourceError: 'a valid source must be provided'

  source: null
  sourceType: null

  getStream: ->
    switch @sourceType
      when 'file'
        @getFileStream source
      when 'url'
        @getUrlStream source
      else
        throw new Error(messages.noSourceError)

  getFileStream: (path) ->
    fs.createReadStream path
