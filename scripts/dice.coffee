# Description:
#   Allows Hubot to roll dice
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot roll (die|one) - Roll one six-sided dice
#   hubot roll dice - Roll two six-sided dice
#   hubot roll <x>d<y><+z> - roll x dice, each of which has y sides, with an optional modifier
#   hubot roll fate - roll 4dF (four six-sided FATE dice)
#   hubot roll <x>dF<+z> - roll x FATE dice, with an optional modifier
#
# Author:
#   ab9

module.exports = (robot) ->
  robot.respond /roll (die|one)/i, (msg) ->
    msg.reply report [rollOne(6)]
  robot.respond /roll dice/i, (msg) ->
    msg.reply report roll 2, 6
  robot.respond /roll (\d+)d(\d+)([+-]\d+)?/i, (msg) ->
    dice = parseInt msg.match[1]
    sides = parseInt msg.match[2]
    modifier = parseInt msg.match[3] || 0
    answer = if sides < 1
      "I don't know how to roll a zero-sided die."
    else if dice > 100
      "I'm not going to roll more than 100 dice for you."
    else
      report (roll dice, sides), modifier
    msg.reply answer
  robot.respond /roll fate/i, (msg) ->
    msg.reply report rollFate()
  robot.respond /roll (\d+)d[fF]([+-]\d+)?/i, (msg) ->
    dice = parseInt msg.match[1]
    modifier = parseInt msg.match[2] || 0
    answer = if dice > 100
      "I'm not going to roll more than 100 dice for you."
    else
      report (rollFate dice), modifier
    msg.reply answer

report = (results, modifier = 0) ->
  if results?
    modifierStr = ""
    if modifier > 0
      modifierStr += " with a bonus of #{Math.abs(modifier)}"
    else if modifier < 0
      modifierStr += " with a penalty of #{Math.abs(modifier)}"
    switch results.length
      when 0
        "I didn't roll any dice."
      when 1
        if modifierStr
          "I rolled a #{results[0]}#{modifierStr}, making #{results[0] + modifier}."
        else
          "I rolled a #{results[0]}."
      else
        total = results.reduce (x, y) -> x + y
        finalComma = if (results.length > 2) then "," else ""
        last = results.pop()
        "I rolled #{results.join(", ")}#{finalComma} and #{last}#{modifierStr}, making #{total + modifier}."

roll = (dice, sides = 0) ->
  rollOne(sides) for i in [0...dice]

rollOne = (sides) ->
  1 + Math.floor(Math.random() * sides)

rollFate = (dice = 4) ->
 2 - rollOne(3) for i in [0...dice]
