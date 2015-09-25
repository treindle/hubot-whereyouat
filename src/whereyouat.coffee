# Description:
#   Remember to someone something
#
# Commands:
#   hubot remember to <user> in <val with unit> <something to remember> - Remember to someone something in a given time eg 5m for five minutes
#   hubot what do you remember? - Show active jobs
#   hubot forget job <id> - Remove a given job
#   hubot rm job <id> - Remove a given job

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
      registerNewJobFromBrain robot, id, job, time...

  robot.respond /where is ([\w\-]+)/i, (msg) ->
    text = ''
    user = msg.match[1]
    for id, job of JOBS
      if id == user
        text += "#{id} said they'll #{job.message} on #{job.pattern}"
    if text.length > 0
      msg.send text
    else
      msg.send "Don't know what to tell you about @#{user}"

  robot.respond /back/i, (msg) ->
    users = [msg.message.user]
    name = users[0].name
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

