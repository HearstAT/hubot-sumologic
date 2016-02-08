HttpClient = require 'scoped-http-client'
moment     = require('moment-timezone')

sumoLogicApiBaseUrl    = process.env.HUBOT_SUMOLOGIC_API_URL 
sumoLogicUiBaseUrl     = process.env.HUBOT_SUMOLOGIC_UI_URL
sumoLogicAccessID      = process.env.HUBOT_SUMOLOGIC_ACCESS_ID
sumoLogicAccessKey     = process.env.HUBOT_SUMOLOGIC_ACCESS_KEY

class SumologicError extends Error
module.exports =
  http: (path) ->
    auth = 'Basic ' + new Buffer(sumoLogicAccessID + ':' + sumoLogicAccessKey).toString('base64')
    HttpClient.create("#{sumoLogicApiBaseUrl}#{path}")
      .headers(Authorization: "#{auth}", Accept: 'application/json')

  missingEnvironmentForApi: (msg) ->
    missingAnything = false
    unless sumoLogicApiBaseUrl?
      msg.send "Sumologic Base URL is missing:  Ensure that HUBOT_SUMOLOGIC_API_URL is set."
      missingAnything |= true
    unless sumoLogicUiBaseUrl?
      msg.send "Sumologic Base URL is missing:  Ensure that HUBOT_SUMOLOGIC_UI_URL is set."
      missingAnything |= true
    unless sumoLogicAccessID?
      msg.send "Sumologic Access ID is missing:  Ensure that HUBOT_SUMOLOGIC_ACCESS_ID is set."
      missingAnything |= true
    unless sumoLogicAccessKey?
      msg.send "Sumologic Access ID is missing:  Ensure that HUBOT_SUMOLOGIC_ACCESS_KEY is set."
      missingAnything |= true
    missingAnything

  get: (url, query, cb) ->
    if typeof(query) is 'function'
      cb = query
      query = {}
    @http(url)
      .query(query)
      .get() (err, res, body) ->
        if err?
          cb(err)
          return
        json_body = null
        switch res.statusCode
          when 200 then json_body = JSON.parse(body)
          else
            cb(new SumologicError("#{res.statusCode} back from #{url}"))

        cb null, json_body

  getDashboards: (dashboard, cb) ->
    @get "/dashboards", (err, json) ->
      if err?
        cb(err)
        return

      cb(null, json)

  getDashboardByID: (dashboardID, cb) ->
    @get "/dashboards/#{dashboardID}/data", (err, json) ->
      if err?
        cb(err)
        return

      cb(null, json)

  getSearchCount: (params, cb) ->
    to        = moment().format('YYYY-MM-DDTHH:mm:ss')
    minutes   = params['minutes']
    from      = moment().subtract(minutes, 'minutes').format('YYYY-MM-DDTHH:mm:ss')
    @get "/logs/search?q=#{params['searchstring']} | count by _sourceCategory, _sourceHost&from=#{from}&to=#{to}", (err, json) ->
      if err?
        cb(err)
        return

      cb(null, json)


