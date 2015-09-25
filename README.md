# hubot-whereyouat
  node module for hubot to check the status of the out of office staff

# Description:
  This is an extention of hubot-rememberto https://github.com/wdalmut/hubot-rememberto
  Records time and away message users set.

# Dependencies:
  "cron": "^1.0.5",
  "moment": "^2.8.3"
# Configuration:
   none

# Commands:
  hubot For <indicate numeric value><s|m|h|d> I will be <text> - Hubot will save the user's away message and time message was set.

  hubot where is <user> - Hubot will respond with the away message and time away message was set.
  
  hubot back - Away message will be cleared

# Notes:
  tdogg: @hubot: For 20m I will be out of office.

  hubot: Got it tdogg! Away message set at Fri Sep 25 2015 21:10:21 GMT+0000 (UTC)

  bosslady: @hubot: where is tdogg? 

  hubot: tdogg said they'll be ooo on Fri Sep 25 2015 21:10:21 GMT+0000 (UTC)

  bosslady: @tdogg! You got 1 minute! ;) 

  tdogg: @hubot: back! 

  hubot: @tdogg, Welcome back!

  bosslady: @tdogg, with 1 second remaining! Nice! 

# Author:
  Teresa Nededog
