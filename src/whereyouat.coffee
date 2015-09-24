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

#   hubot: @boss, it is Wed Sep 23 2015 18:50:06 GMT+0000 (UTC) and tdogg sa, "I'll be back in 20." on Wed Sep 23 2015 18:31:41 GMT+0000 (UTC)

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
  user = Math.floor(Math.random() * 1000000) while !user? || TASK[user]
  text = registerNewTask robot, user, pattern, user, message
  robot.brain.data.things[user] = text.serialize()
  user

registerNewTaskFromBrain = (robot, user, pattern, user, message) ->
  registerNewTask(robot, user, pattern, user, message)

registerNewTask = (robot, user, pattern, user, message) ->
  text = new Task(user, pattern, user, message)
  text.start(robot)
  TASK[user] = text

unregisterTask = (robot, user)->
  if TASK[user]
    TASK[user].stop()
    delete robot.brain.data.ooo[user]
    delete TASK[user]
    return yes
  no

handleNewTask = (robot, msg, user, pattern, message) ->
    user = createNewText robot, pattern, user, message
    msg.send "Alright #{user.name}. #{pattern} recorded"


module.exports = (robot) -> 
#ooo means "Out Of Office"
  robot.brain.data.ooo or = {}

  robot.brain.on 'loaded', ->
    for own user, task of robot.brain.data.ooo
      console.log user
      registerNewTaskFromBrain robot, user, task...

  robot.respond /where is ([\w\-]+)/i, (msg) ->
    text = ''
      for user, task of TASKS
        room = task.user.reply_to || task.user.room
        if room == msg.message.user.reply_to or room == msg.message.user.room
          text += "#{user}: #{task.pattern} @#{room} \"#{task.message}\"\n"
      if text.length > 0
        msg.send text
      else
        msg.send "Got nothing! We should all be present!"

  robot.respond /(I'm back|back)/i, (msg) ->
    reqUser = msg.match[2]
    for user, task of TASKS
      if (reqUser == user)
        if unregisterTask(robot, reqUser)
          msg.send "Task #{user} sleep with the fishes..."
        else
          msg.send ":haunted: Can't seem to forget about it..."

  robot.respond /(.*) (I am|I'm|I'll) (be|in|at) (out|back|in|at|on|under|above) (.*) (in|for) (\d+)([s|m|h|d])/i, (msg) ->
    name = msg.match[1]
    at = msg.match[2]
    time = msg.match[3]
    something = msg.match[4]

    if /^me$/i.test(name.trim())
      users = [msg.message.user]
    else
      users = robot.brain.usersForFuzzyName(name)

    if users.length is 1
      switch time
        when 's' then handleNewJob robot, msg, users[0], moment().add(at, "second").toDate(), something
        when 'm' then handleNewJob robot, msg, users[0], moment().add(at, "minute").toDate(), something
        when 'h' then handleNewJob robot, msg, users[0], moment().add(at, "hour").toDate(), something
        when 'd' then handleNewJob robot, msg, users[0], moment().add(at, "day").toDate(), something
    else if users.length > 1
      msg.send "Be more specific, I know #{users.length} people " +
        "named like that: #{(user.name for user in users).join(", ")}"
    else
      msg.send "#{name}? Never heard of 'em"

  class Job
  constructor: (pattern, user, message) ->
    @pattern = pattern
    # cloning user because adapter may touch it later
    clonedUser = {}
    clonedUser[k] = v for k,v of user
    @user = clonedUser
    @message = message

  start: (robot) ->
    @cronjob = new cronJob(@pattern, =>
      @sendMessage robot, ->
      unregisterJob robot
    )
    @cronjob.start()

  stop: ->
    @cronjob.stop()

  serialize: ->
    [@pattern, @user, @message]

  sendMessage: (robot) ->
    envelope = user: @user, room: @user.room
    message = @message
    if @user.mention_name
      message = "Hey @#{envelope.user.mention_name} remember: " + @message
    else
      message = "Hey @#{envelope.user.name} remember: " + @message
    robot.send envelope, message

