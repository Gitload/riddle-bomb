timer = new Chronos.Timer()
timer.start()

@RiddleBombTime =
  getTime: ->
    timer.time.get()
