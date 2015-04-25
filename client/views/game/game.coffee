Template.game.helpers
  isEndedGame: ->
    RiddleBomb.getGameWinner()

Template.endedGame.helpers
  winner: ->
    RiddleBomb.getGameWinner()

Template.game.events
  'click .accept-invitation' : ->
    RiddleBomb.startGame()
