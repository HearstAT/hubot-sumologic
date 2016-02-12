# Description
#   Sumologic integration for Hubot
#
# Configuration:
#   HUBOT_SUMOLOGIC_API_URL
#   HUBOT_SUMOLOGIC_UI_URL
#   HUBOT_SUMOLOGIC_ACCESS_ID 
#   HUBOT_SUMOLOGIC_ACCESS_KEY
#
# Commands:
#   hubot sumo help - hubot commands for sumologic integration
#   hubot sumo dashboards - return list of dashboards
#   hubot sumo dashboard <id> data - return list of dashboards
#   hubot sumo search count <query> - return total count and count of category and host for query (last 60 minutes)
#   hubot sumo search count <query> last <minutes> - return total count and count of category and host for query for specified number of minutes
#   hubot sumo ui url - return a link to the UI
#
# Notes:
#   <optional notes required for the script>
#
# Authors:
#   Aaron Blythe

sumologic = require('../sumologic')
async = require('async')
inspect = require('util').inspect
moment = require('moment-timezone')

sumoLogicUiBaseUrl     = process.env.HUBOT_SUMOLOGIC_UI_URL

module.exports = (robot) ->
  robot.respond /sumo dashboards/i, (msg) ->
    msg.finish()
    if sumologic.missingEnvironmentForApi(msg)
      return
    sumologic.getDashboards msg.match[3], (err, dashboards) ->
      if err?
        robot.emit 'error', err, msg
        return
      msg.send formatDashboardsOutput(dashboards)

  robot.respond /sumo dashboard (.+) data/i, (msg) ->
    msg.finish()
    if sumologic.missingEnvironmentForApi(msg)
      return
    sumologic.getDashboards msg.match[3], (err, dashboards) ->
      if err?
        robot.emit 'error', err, msg
        return
      else 
        sumologic.getDashboardByID msg.match[1], (err, dashboard) ->
          if err?
            robot.emit 'error', err, msg
            return
          msg.send formatDashboardDataOutput(dashboard, dashboards, msg.match[1])

  robot.respond /sumo search count (.+) last (.+)$/i, (msg) ->
    msg.finish()
    if sumologic.missingEnvironmentForApi(msg)
      return
    params = 
      searchstring: msg.match[1]
      minutes: msg.match[2]
    sumologic.getSearchCount params, (err, search) ->
      if err?
        robot.emit 'error', err, msg
        return
      msg.send formatSearchCountOutput(search)

  robot.respond /sumo search count (.+)?$/i, (msg) ->
    msg.finish()
    if sumologic.missingEnvironmentForApi(msg)
      return
    params = 
      searchstring: msg.match[1]
      minutes: 60
    sumologic.getSearchCount params, (err, search) ->
      if err?
        robot.emit 'error', err, msg
        return
      msg.send formatSearchCountOutput(search)

  robot.respond /sumo ui url/i, (msg) ->
    msg.finish()
    if sumologic.missingEnvironmentForApi(msg)
      return
    msg.send sumoLogicUiBaseUrl

  robot.respond /sumo help/i, (msg) ->
    cmds = renamedHelpCommands(robot)
    msg.send cmds.join("\n")

  formatDashboardsOutput = (db) ->
    list = ""
    for i in db.dashboards
      list += "ID: #{i.id}, Name: #{i.title} \n"
    list

  formatDashboardDataOutput = (db, dbs, id) ->
    list = ""
    titles = {}
    # cycle through the panels on this dashboard
    for d in dbs.dashboards
      if d.id == id/1
        for t in d.dashboardMonitors
          titles[t.id] = t.title
    
    for i in db.dashboardMonitorDatas
      headers = ""
      for f in i.fields
        headers += "**#{f.name}** "
      if i.records.length <= 0
        list += "#{headers} \n"
        list += "ID: #{i.id} no results \n\n"
      else
        data = ""
        for r in i.records
          headers = "|"
          data += "|"
          for k,v of r.map
            headers += " #{k} |"
            if k is "_timeslice"
              data += " #{moment.utc(v/1).format()} |"
            else
              data += " #{v} |"
          data += "\n"
        list += "#{titles[i.id]} \n"
        list += "#{headers} \n"
        list += "#{data} \n"
    list

  formatSearchCountOutput = (search) ->
    list = ""
    for i in search
      list += "Count #{i._count}, Category: #{i._sourcecategory}, Host: #{i._sourcehost} \n"
    list

renamedHelpCommands = (robot) ->
  robot_name = robot.alias or robot.name
  cmds = robot.helpCommands()
  cmds = (cmd for cmd in cmds when cmd.match(/hubot sumo/))
  help_commands = cmds.map (command) ->
    command.replace /^hubot/i, robot_name
  help_commands.sort()