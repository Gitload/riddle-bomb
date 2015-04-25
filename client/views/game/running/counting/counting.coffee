Template.counting.helpers
  breakTime: ->
    RiddleBomb.getCurrentBreakTime()
  roundWinner: ->
    roundNumber = RiddleBomb.getCurrentGame().getCurrentRoundNumber()
    if roundNumber > 0
      winner = RiddleBomb.getRoundWinner(roundNumber - 1)
      return winner