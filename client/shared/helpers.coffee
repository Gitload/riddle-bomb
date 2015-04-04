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

Template.registerHelper 'socialMedia', ->
	_.map Config.socialMedia, (obj)->
		obj