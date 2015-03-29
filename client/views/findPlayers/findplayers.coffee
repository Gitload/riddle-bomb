Template.findPlayers.helpers
  facebookFriends: ->
    return RiddleBomb.getFacebookFriends()
  playerByFacebookUser: (facebookUser=@) ->
    return RiddleBomb.getUserByFacebookUser facebookUser