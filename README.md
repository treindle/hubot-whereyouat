# hubot-whereyouat
node module for hubot to check the status of all out of office staff

# Description:
   Records time and away message users set.

# Dependencies:
   none

# Configuration:
   none

# Commands:
   hubot I am in <text>
         I'm in <text>
         I am at <text>
         I'm at <text>
         I will be back/in/at/on/under <text>
         I'll be back/in/at/on/under/above <text> -Hubot will save the user's away message and time message was set.
   hubot where is <user> - Hubot will respond with the away message and time away message was set.
   hubot I'm back
         back - Away message will be cleared with time of return

# Notes:
   tdogg: @hubot: I'll be back in 20.

   hubot: tdogg, your away message "I'll be back in 20" has been recorded from Wed Sep 23 2015 18:31:00 GMT+0000 (UTC)

   bosslady: @hubot: where is tdogg? 

   hubot: @boss, it is Wed Sep 23 2015 18:50:06 GMT+0000 (UTC) and tdogg said, "I'll be back in 20." on Wed Sep 23 2015 18:31:41 GMT+0000 (UTC)

   bosslady: @tdogg! You got 1 minute! ;) 

   tdogg: @hubot: I'm back! 

   hubot: @tdogg! Welcome back! Your away message has been cleared on Wed Sep 23 2015 18:50:59 GMT+0000 (UTC)

   bosslady: @tdogg, with 1 second remaining! Nice! 

# Author:
   Teresa Nededog