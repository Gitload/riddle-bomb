Template.findPlayers.helpers
  facebookFriends: ->
    RiddleBomb.getUsersByFacebookFriends()

Template.player.helpers
  isDisabled: () ->
    (@.isInvited || @.isInRunningGame)

  getIcon: () ->
    if @.isInvited
      return 'fa fa-envelope'
    if @.isInRunningGame
      return 'fa fa-play-circle'
    return 'fa fa-bell'

Template.player.events
  'click .start-game' : ->
    RiddleBomb.createNewGame
      invitee: @
