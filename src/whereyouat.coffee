# Description:
#   This is an extention of hubot-rememberto https://github.com/wdalmut/hubot-rememberto
#   Records time and away message users set.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot for <indicate numeric value><s|m|h|d> <away message> - Save the user's away message and time message was set.
#   hubot where is <user> - User's current away message and time
#   hubot back - Away message will be cleared


cronJob = require('cron').CronJob
moment = require('moment')
tz = require('moment-timezone')

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
      registerNewJobFromBrain robot, id, job, time...

  robot.respond /where is ([\w\-]+)/i, (msg) ->
    text = ''
    user = msg.match[1]
    for id, job of JOBS

      #uncomment this code for timer
      # time = Math.ceil(job.cronjob._timeout._idleTimeout / 1000)

      #comment this code for timer
      if id == user
        serverTime = moment(job.pattern).format();
        june = moment(serverTime)
        psttime = june.tz('America/Los_Angeles').format('lll')
        text += "On #{psttime} PST, #{id} said, \"#{job.message}\""


        #uncomment this code for timer
        #if time < 60
          #text += "#{id} said: #{job.message} for #{time} s on #{job.pattern}"
        #else if time > 60 || time <= 3600
          #text += "#{id} said: #{job.message} for #{time/60} m on #{job.pattern}"
        #else if time > 3600 || time <= 86400
          #text += "#{id} said: #{job.message} for #{time/3600} h on #{job.pattern}"
        #else if time > 86400
          #text += "#{id} said: #{job.message} for #{time/86400} d on #{job.pattern}"
      
    if text.length > 0
      msg.send text
    else
      msg.send ":fearful: @#{user} didn't tell me where they'd be."

  robot.respond /back/i, (msg) ->
    users = [msg.message.user]
    name = users[0].name
    something = msg.match[1]
    for id, job of JOBS
      if (id == name)
        unregisterJob(robot, name)
        msg.send "@#{name}, welcome back! :tada:"
      else
        msg.send ":fearful: @#{name}, didn't even know you were gone!"

  robot.respond /who's out/i, (msg) ->
    text = ''
    for id, job of JOBS
      room = job.user.reply_to || job.user.room
      if id == true
        text += "#{id}\n"
    if text.length > 0
      msg.send text
    else
      msg.send "Everyone should be here!"

  robot.respond /(.*) in (\d+)([s|m|h|d])/i, (msg) ->
    users = [msg.message.user]
    name = users[0].name
    something = msg.match[1]
    at = msg.match[2]
    time = msg.match[3]


    if users.length is 1
      switch time
        when 's' then handleNewJob robot, msg, users[0], moment().add(at, "second").toDate(), something
        when 'm' then handleNewJob robot, msg, users[0], moment().add(at, "minute").toDate(), at, time, something
        when 'h' then handleNewJob robot, msg, users[0], moment().add(at, "hour").toDate(), at, time, something
        when 'd' then handleNewJob robot, msg, users[0], moment().add(at, "day").toDate(), at, time, something
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
      @sendMessage robot
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
      message = "Hey @#{envelope.user.name}! Time's up. Everything alright? :worried:"
    robot.send envelope, message