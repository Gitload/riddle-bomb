onDrawAdded = ->
currentDraws = 0

Games.find().observe
  changed: (newDoc, oldDoc) ->
    if newDoc.draws.length != currentDraws
      currentDraws = newDoc.draws.length
      onDrawAdded(_.last newDoc.draws)

@Game = (gameId, options = {})   ->
  currentDraws = 0
  onDrawAdded = options.onDrawAdded || ->

  game = Games.find gameId
  return game