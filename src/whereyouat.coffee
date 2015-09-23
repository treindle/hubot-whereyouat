# Description:
#   Records time and away message users set.
#
# Dependencies:
#   none
#
# Configuration:
#   none
#
# Commands:
#   hubot I am in <text>
#         I'm in <text>
#         I am at <text>
#         I'm at <text>
#         I will be back/in/at/on/under <text>
#         I'll be back/in/at/on/under/above <text> -Hubot will save the user's away message and time message was set.
#   hubot where is <user> - Hubot will respond with the away message and time away message was set.
#   hubot I'm back
#         back - Away message will be cleared with time of return
#
# Notes:
#   tdogg: @hubot: I'll be back in 20.

#   hubot: tdogg, your away message "I'll be back in 20" has been recorded from Wed Sep 23 2015 18:31:00 GMT+0000 (UTC)

#   bosslady: @hubot: where is tdogg? 

#   hubot: @boss, it is Wed Sep 23 2015 18:50:06 GMT+0000 (UTC) and tdogg said, "I'll be back in 20." on Wed Sep 23 2015 18:31:41 GMT+0000 (UTC)

#   bosslady: @tdogg! You got 1 minute! ;) 

#   tdogg: @hubot: I'm back! 

#   hubot: @tdogg! Welcome back! Your away message has been cleared on Wed Sep 23 2015 18:50:59 GMT+0000 (UTC)

#   bosslady: @tdogg, with 1 second remaining! Nice! 
#
# Author:
#   Teresa Nededog

cronTask = require('cron').CronTask
moment = require('moment')

TASK = {}

createNewTask = (robot, pattern, user, message) ->
  id = Math.floor(Math.random() * 1000000) while !id? || TASK[id]
  text = registerNewTask robot, id, pattern, user, message
  robot.brain.data.things[id] = text.serialize()
  id

registerNewTaskFromBrain = (robot, id, pattern, user, message) ->
  registerNewTask(robot, id, pattern, user, message)

registerNewTask = (robot, id, pattern, user, message) ->
  text = new Task(id, pattern, user, message)
  text.start(robot)
  TASK[id] = text

unregisterTask = (robot, user)->
  if TASK[user]
    TASK[user].stop()
    delete robot.brain.data.ooo[user]
    delete TASK[user]
    return yes
  no

handleNewTask = (robot, msg, user, pattern, message) ->
    id = createNewText robot, pattern, user, message
    msg.send "Alright #{user.name}. #{pattern} recorded"


module.exports = (robot) -> 
#ooo means "Out Of Office"
  robot.brain.data.ooo or = {}

  robot.brain.on 'loaded', ->
    for own id, task of robot.brain.data.ooo
      console.log id
      registerNewTaskFromBrain robot, id, task...

  robot.respond /(I am|I'm|I'll) (be|in|at) (back|in|at|on|under|above)/i, (msg)
    text = ''
      for id, task of TASKS
        room = task.user.reply_to || task.user.room
        if room == msg.message.user.reply_to or room == msg.message.user.room
          text += "#{id}: #{task.pattern} @#{room} \"#{task.message}\"\n"
      if text.length > 0
        msg.send text
      else
        msg.send "Got nothing! We should all be present!"

  robot.respond /(forget|rm|remove) task (\d+)/i, (msg) ->
    reqId = msg.match[2]
    for id, task of TASKS
      if (reqId == id)
        if unregisterTask(robot, reqId)
          msg.send "Task #{this.id} sleep with the fishes..."
        else
          msg.send ":haunted: Can't seem to forget about it..."
