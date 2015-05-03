Template.runningGame.helpers
  currentQuestion: ->
    RiddleBomb.getCurrentQuestion()

  points: (user) ->
    RiddleBomb.getPointsByUser(user)

  drawTime: () ->
    seconds = RiddleBomb.getCurrentDrawTime()
    max = RiddleBomb.getConfig("timeForDraw")
    percent = Math.round 100 / max * seconds
    state = switch
      when percent > 70 then 'success'
      when percent  > 40 then 'warning'
      else 'danger'

    drawTime =
      seconds : seconds
      min: 0
      max: max
      percent: percent
      state: state

  isPaused: () ->
    (RiddleBomb.getCurrentBreakTime() > 0)

Template.runningGame.events
  "submit .submit-answer": (event) ->
    answer = event.target.answer.value
    RiddleBomb.submitAnswer answer
    return false

  "blur input#answer": (event, template) ->
    if Modernizr.touch && event.target.value
      template.$('.submit-answer').submit()