Template.findPlayers.helpers
  facebookFriends: ->
    return RiddleBomb.getUsersByFacebookFriends()

Template.player.events
  'click .start-game' : ->
    RiddleBomb.createNewGame(
      invitee: @
    )
