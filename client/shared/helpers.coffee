Template.registerHelper 'Config', ->
	Config

Template.registerHelper 'NCSchemas', ->
	NCSchemas

Template.registerHelper 'playerName', ->
  return this.player.profile.firstName

Template.registerHelper 'socialMedia', ->
	_.map Config.socialMedia, (obj)->
		obj