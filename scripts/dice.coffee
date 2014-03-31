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
#   hubot roll fate - roll 4dF (four six-sided FATE dice)
#   hubot roll fate x3 - roll a set of 4dF 3 times
#   hubot roll <x>d<y><+z> - roll x dice, each of which has y sides, with an optional modifier
#   hubot roll <x>dF<+z> - roll x FATE dice, with an optional modifier
#   !roll (die|one) - Roll one six-sided dice
#   !roll dice - Roll two six-sided dice
#   !fate - roll 4dF (four six-sided FATE dice)
#   !fate x3 - roll a set of 4dF 3 times
#   !roll <x>d<y><+z> - roll x dice, each of which has y sides, with an optional modifier
#   !roll <x>dF<+z> - roll x FATE dice, with an optional modifier
#
# Author:
#   ab9

util = require 'util'

module.exports = (robot) ->
  robot.respond /roll (die|one)/i, (msg) ->
    msg.reply report [rollOne(6)]
  robot.hear /^!roll (die|one)/i, (msg) ->
    msg.reply report [rollOne(6)]
  robot.respond /roll dice/i, (msg) ->
    msg.reply report roll 2, 6
  robot.hear /^!roll dice/i, (msg) ->
    msg.reply report roll 2, 6
  robot.respond (new RegExp 'roll ' + fatePatternStr, 'i'), parseFate
  robot.hear (new RegExp '^!' + fatePatternStr, 'i'), parseFate
  robot.respond (new RegExp('roll ' + dicePatternStr, 'i')), parseDice
  robot.hear (new RegExp('^!roll ' + dicePatternStr, 'i')), parseDice

fatePatternStr = 'fate\\s?(x\\d+)?\\s?([+-]\\d+)?'
dicePatternStr = '(\\d+)d(f|\\d+)([+-]\\d+)?'

parseFate = (msg) ->
    times = if msg.match[1] and msg.match[1][0] is 'x'
      parseInt msg.match[1].slice(1)
    else 1
    modifier = parseInt msg.match[2] || 0
    while times--
      msg.reply report rollFate(), modifier

parseDice = (msg) ->
  dice = parseInt msg.match[1]
  sides = msg.match[2]
  modifier = parseInt msg.match[3] || 0
  answer = if sides < 1
    "I don't know how to roll a zero-sided die."
  else if dice > 100
    "I'm not going to roll more than 100 dice for you."
  else if sides.toLowerCase() is 'f'
    report (rollFate dice), modifier
  else
    report (roll dice, parseInt sides), modifier
  msg.reply answer

report = (results, modifier = 0) ->
  if results?
    modifierStr = if modifier > 0
      " with a +#{modifier} bonus"
    else if modifier < 0
      " with a #{modifier} penalty"
    else ""
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
