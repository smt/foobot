# Description:
#   Some helpful integrations with the BGG XML API2
#   (http://boardgamegeek.com/wiki/page/BGG_XML_API2)
#
# Dependencies:
#   "bgg": "0.2.1"
#
# Configuration:
#   None
#
# Commands:
#   !bgg user <username> - link to BoardGameGeek user's profile
#   !bgg collection <username> - link to BoardGameGeek user's collection
#   !bgg search <query> - link(s) to BoardGameGeek search results(s)
#
# Author:
#   smt

bgg = require('bgg')

module.exports = (robot) ->
  robot.error (err, msg) ->
    robot.logger.error err
    if msg?
      msg.reply err
  robot.hear /^!bgg user (\S+)/i, (msg) ->
    bgg('user', { name: msg.match[1] }).then(
      (results) ->
        msg.reply "#{results.user.avatarlink.value}\n#{results.user.firstname.value} #{results.user.lastname.value}'s BGG profile: http://boardgamegeek.com/user/#{results.user.name}\n#{cite()}"
      (error) ->
        robot.emit('error', error) )
  robot.hear /^!bgg owned (\S+)/i, (msg) ->
    bgg('collection', { username: msg.match[1], own: 1 }).then(
      (results) ->
        msg.reply "#{results.user.avatarlink.value}\n#{results.user.firstname.value} #{results.user.lastname.value}'s collection (#{results.items.totalitems} games): http://boardgamegeek.com/collection/user/#{msg.match[1]}?own=1\n#{cite()}"
      (error) ->
        robot.emit('error', error) )
  robot.hear /^!bgg search (.*)/i, (msg) ->
    bgg('search', { query: msg.match[1], type: 'boardgame', exact: 1 }).then(
      (results) ->
        if results and results.items and results.items.item
          item = results.items.item
          getId = (i) -> i.id
          id = if item.length
            (getId i for i in item).join(',')
          else
            getId item
          bgg('thing', { id: id, type: 'boardgame', stats: 1 }).then(
            (thing) ->
              item = thing.items.item;
              getStr = (i) ->
                s = "#{i.thumbnail}\n#{if i.name.length then i.name[0].value else i.name.value} (#{i.yearpublished.value}) - http://boardgamegeek.com/boardgame/#{i.id}"
                stats = (rank) ->
                  s += "\n#{rank.friendlyname}: #{rank.value} (#{rank.bayesaverage} Avg Rating)"
                if i.statistics.ratings.ranks.rank.length
                  stats rank for rank in i.statistics.ratings.ranks.rank
                s
              str = if item.length
                (getStr j for j in item).join('\n\n')
              else
                getStr item
              msg.reply "#{str}\n#{cite()}"
            (error) ->
              robot.emit('error', error) )
        else
          robot.emit('error', 'No results', msg)
      (error) ->
        robot.emit('error', error) )

cite = -> "(data courtesy of BoardGameGeek)"
