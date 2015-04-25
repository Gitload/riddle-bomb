@Game = (gameId, options = {})   ->
  game = Games.find gameId
  return game