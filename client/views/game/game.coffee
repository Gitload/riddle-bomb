Template.runningGame.helpers
  currentQuestion: ->
    RiddleBomb.getCurrentQuestion()

  answers: ->
    RiddleBomb.getAnswersWithStatus()

  hasTurn: ->
    RiddleBomb.userHasTurn()


Template.game.events
  'click .accept-invitation' : ->
    RiddleBomb.startGame @

Template.runningGame.events
  "submit .submit-answer": (event) ->
    answer = event.target.answer.value
    RiddleBomb.submitAnswer answer
    return false