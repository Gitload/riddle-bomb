Template.registerHelper 'Config', ->
	Config

Template.registerHelper 'NCSchemas', ->
	NCSchemas

Template.registerHelper 'playerName', ->
  return this.player.profile.firstName

Template.registerHelper 'game', ->
    RiddleBomb.getCurrentGame()

Template.registerHelper 'invitedUser', ->
  RiddleBomb.getInvitedUserByGame()

Template.registerHelper 'gameAdmin', ->
    RiddleBomb.getAdminUserByGame()

Template.registerHelper 'isGameAdmin', (user = Meteor.user()) ->
  RiddleBomb.isGameAdminUser(user)

Template.registerHelper 'isInvitedUser', (user = Meteor.user()) ->
    RiddleBomb.isInvitedUser(user)

Template.registerHelper 'isPendingGame', ->
  RiddleBomb.isPendingGame()

Template.registerHelper 'hasRunningGame', ->
  (RiddleBomb.getRunningGamesForUser())

Template.registerHelper 'socialMedia', ->
	_.map Config.socialMedia, (obj)->
		obj

getNotificationFilter = ->
  pendingGameIds = _.map RiddleBomb.getPendingGames().fetch(), (game) ->
    return game._id
  notificationFilter = {$or: [{"data.gameId" : {$in: pendingGameIds}}]}
  return notificationFilter

Template.registerHelper 'Notifications', (options) ->
  if typeof window['Notifications'] != 'undefined'
    if options instanceof Spacebars.kw and options.hash
      limit = options.hash.limit if options.hash.limit?
      order = {read: 1, date: -1} if options.hash.unreadFirst?
    else
      limit = 0
      order = {date: -1}

    notifications = Notifications.find(
      getNotificationFilter(),
      {limit: limit, sort: order}).
    fetch()
    return notifications

Template.registerHelper 'notificationCount', ->
  if typeof window['Notifications'] != 'undefined'
    Notifications.find(_.extend getNotificationFilter(), {read: false}).count()