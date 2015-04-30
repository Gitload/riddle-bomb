Template.answers.helpers
  answers: ->
    RiddleBomb.getAnswersWithStatus()

Template.answers.rendered = ->
  Tracker.autorun ->
    windowHeight = rwindow.$height()
    positionTop = $('#answers').offset().top
    $('#answers').css('height', windowHeight - positionTop + 'px')

  Tracker.autorun ->
    lastDraw = RiddleBomb.getCurrentGame().getLastDraw()
    if lastDraw && lastDraw.correctAnswer
      $.smoothScroll
        scrollTarget: "[data-title='#{lastDraw.usedAnswer}']"
        scrollElement: $('#answers')
        offset: ($('#answers').height() / 2) * (-1)