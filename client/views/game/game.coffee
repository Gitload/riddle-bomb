Template.game.helpers
  game: ->
    return RiddleBomb.getCurrentGame()

  isInvitedUser: ->
    return (RiddleBomb.getInvitedUserByGame()._id == Meteor.user()._id)

  isPendingGame: ->
    return RiddleBomb.isPendingGame()
