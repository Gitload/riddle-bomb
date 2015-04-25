Template.game.helpers
  isEndedGame: ->
    RiddleBomb.gameHasEnded()

Template.endedGame.helpers
  winner: ->
    RiddleBomb.getGameWinner()

Template.game.events
  'click .accept-invitation' : ->
    RiddleBomb.startGame()
