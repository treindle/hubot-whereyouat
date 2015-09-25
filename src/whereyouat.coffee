# Description:
#   Records time and away message users set.
#
# Dependencies:
#   "cron": "^1.0.5",
#   "moment": "^2.8.3"
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
#   hubot user is back - Away message will be cleared
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

cronJob = require('cron').CronJob
moment = require('moment')

JOBS = {}

createNewJob = (robot, pattern, user, message, time) ->
  id = user.name || JOBS[id]
  job = registerNewJob robot, id, pattern, user, message, time
  robot.brain.data.things[id] = job.serialize()
  id

registerNewJobFromBrain = (robot, id, pattern, user, message, time) ->
  registerNewJob(robot, id, pattern, user, message, time)

registerNewJob = (robot, id, pattern, user, message, time) ->
  job = new Job(id, pattern, user, message, time)
  job.start(robot)
  JOBS[id] = job

unregisterJob = (robot, id, user)->
  if JOBS[id]
    JOBS[id].stop()
    delete robot.brain.data.things[id]
    delete JOBS[id]
    return yes
  no

handleNewJob = (robot, msg, user, pattern, message, time) ->
    id = createNewJob robot, pattern, user, message, time
    msg.send "Got it #{user.name}! Away message set at #{pattern}"

module.exports = (robot) ->
  robot.brain.data.things or= {}

  # The module is loaded right now
  robot.brain.on 'loaded', ->
    for own id, job of robot.brain.data.things
      console.log id
      registerNewJobFromBrain robot, id, job, time...

  robot.respond /where is ([\w\-]+)/i, (msg) ->
    text = ''
    user = msg.match[1]
    for id, job of JOBS
      if id == user
        text += "#{id} said they'll #{job.message} on #{job.pattern} "
    if text.length > 0
      msg.send text
    else
      msg.send "Don't know what to tell you about @#{user}"

  robot.respond /(.*) is back/i, (msg) ->
    name = msg.match[1]
    for id, job of JOBS
      if (id == name)
        unregisterJob(robot, name)
        msg.send "@#{name}, welcome back! "
      else
        msg.send "@#{name}, didn't even know you were gone!"


  robot.respond /for (\d+)([s|m|h|d]) (.*) will (.*)/i, (msg) ->
    name = msg.match[3]
    at = msg.match[1]
    time = msg.match[2]
    something = msg.match[4]

    if /^(i)$/i.test(name.trim())
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
  constructor: (id, pattern, user, message, time) ->
    @id = id
    @pattern = pattern
    @time = time
    # cloning user because adapter may touch it later
    clonedUser = {}
    clonedUser[k] = v for k,v of user
    @user = clonedUser
    @message = message

  start: (robot) ->
    @cronjob = new cronJob(@pattern, =>
      @sendMessage robot, ->
      unregisterJob robot, @id
    )
    @cronjob.start()

  stop: ->
    @cronjob.stop()

  serialize: ->
    [@pattern, @user, @message, @time]

  sendMessage: (robot) ->
    envelope = user: @user, room: @user.room, time: @user.time
    message = @message
    if @user.mention_name
      message = "Hey @#{envelope.user.mention_name}! You never checked back in!"
    else
      message = "Hey @#{envelope.user.name}! Time's up. Everything alright?"
    robot.send envelope, message

