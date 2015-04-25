facebookFriends = new ReactiveVar()

if Meteor.isClient
  if Meteor.userId()
    Meteor.subscribe 'user', () ->
      facebookFriends.set FacebookCollections.getFriends('me').find {}

getUserById  = (id) ->
  return Meteor.findOne id

currentGame = false
trackerChecks = new ReactiveVar()

config =
  pointsToWin : 5
  timeForDraw: 30
  timeForBreak: 5

getSeconds = (game) ->
  draws = game.draws
  startedAt = if draws.length == 0 then game.startedAt else draws[draws.length - 1].endedAt
  seconds = Math.round((RiddleBombTime.getTime() - startedAt.getTime()) / 1000)
  return seconds

@RiddleBomb =

  getUsersByFacebookFriends: () ->
    facebookIds = _.map facebookFriends.get().fetch(), (doc) ->
      doc.id
    collection = Meteor.users
    invitedUserIds = _.flatten _.map @getPendingGamesForAdmin().fetch(), (doc) ->
      doc.userIds

    return collection
      .find
        "services.facebook.id": {$in: facebookIds}
      .map (user) ->
        user.isInvited = (invitedUserIds.indexOf(user._id) > -1)
        user.isInRunningGame = RiddleBomb.userIsInRunningGame(user)
        console.log user
        return user

  getUsedQuestionIdsByUser: (user) ->
    games = Games.find
      userIds : user._id

    questionsIds = _.map games.fetch(), (doc) ->
      doc.questionIds

    return _.flatten questionsIds

  getCurrentDrawTime: () ->
    console.log 'get current draw time'
    game = @getCurrentGame()
    seconds = getSeconds game
    breakSeconds = if game.getCurrentDraws().length == 0 then config.timeForBreak else 0
    return (config.timeForDraw + breakSeconds - seconds)

  getCurrentBreakTime: () ->
    console.log 'get current break time'
    game = @getCurrentGame()
    seconds = getSeconds(game)
    if game.getCurrentDraws().length == 0
      console.log (config.timeForBreak - seconds)
      return config.timeForBreak - seconds
    else
      console.log '0'
      return 0

  isPendingGame: (game = @getCurrentGame()) ->

    return (!game.endedAt && !game.startedAt)

  getPendingGames: ->
    Games.find
      endedAt: null
      startedAt: null

  getPendingGamesForAdmin : (user = Meteor.user()) ->
    Games.find
      userIds: user._id
      endedAt: null
      startedAt: null
      adminUserId: user._id

  getPendingGamesForInvitee : (user = Meteor.user()) ->
    Games.find
      userIds: user._id
      endedAt: null
      startedAt: null
      adminUserId: {$not: user._id}

  getRunningGamesForUser : (user = Meteor.user()) ->
    if(!user)
      return
    Games.find
      userIds: user._id
      endedAt: null
      startedAt : {$not: null}

  userIsInRunningGame: (user) ->
    return (@getRunningGamesForUser(user) && @getRunningGamesForUser(user).count() > 0)

  getCurrentGame : ->
    if Router.current().route.getName() != 'game'
      return
    gameId = Router.current().data().gameId
    if !currentGame || currentGame._id != gameId
      gameId = Router.current().data().gameId
      currentGame = new Game gameId
    return currentGame.fetch()[0]

  getAdminUserByGame: (game = @getCurrentGame()) ->
    Meteor.users.findOne game.adminUserId

  getInvitedUserByGame: (game = @getCurrentGame()) ->
    invitedUserId = _.without(game.userIds, game.adminUserId)[0]
    return Meteor.users.findOne invitedUserId


  getAvailableQuestions: (users) ->
    usedQuestionsIds = _.flatten (@getUsedQuestionIdsByUser(user) for user in users)

    availableQuestions = Questions.find()
      ##"_id" : {$nin: usedQuestionsIds}

    return availableQuestions

  createNewGame: (options) ->
    users = [Meteor.user(), options.invitee];
    availableQuestions = @getAvailableQuestions users;

    questionForGame = _.shuffle(availableQuestions.fetch()).slice 0, config.pointsToWin * 2

    Games.insert
      userIds : (user._id for user in users)
      adminUserId: users[0]._id
      questionIds: (question._id for question in questionForGame)

  startGame: (game = @getCurrentGame()) ->
    Games.update game._id,
      $set:
        startedAt: new Date()

  endGame: (game = @getCurrentGame()) ->
    if !@gameHasEnded()
      Games.update game._id,
        $set:
          endedAt: new Date()

  getCurrentQuestion: ->
    @getCurrentGame().getCurrentQuestion()

  userHasTurn: (user = Meteor.user()) ->
    currentDrawNumber = @getCurrentGame().getCurrentDrawNumber()
    isInvitedUser = @isInvitedUser(user)
    isOddDrawNumber = currentDrawNumber % 2
    if isOddDrawNumber
      return (isInvitedUser)
    else
      return (!isInvitedUser)

  isInvitedUser: (user = Meteor.user()) ->
    (RiddleBomb.getInvitedUserByGame()._id == user._id)

  isGameAdminUser: (user = Meteor.user()) ->
    (RiddleBomb.getAdminUserByGame()._id == user._id)

  getAnswersWithStatus: ->
    @getCurrentGame().getAnswersWithStatus()

  getRoundWinner: (roundNumber) ->
    finalDraw = @getCurrentGame().roundHasFinalDraw(roundNumber)
    if finalDraw
      user = Meteor.users.findOne(finalDraw.draw.userId)
      return if finalDraw.correct then user else @getOppositePlayer(user)
    else
      return false

  getGameWinner: () ->
    users = [@getInvitedUserByGame(), @getAdminUserByGame()]
    winner = false
    for user in users
      if RiddleBomb.getPointsByUser(user) >= config.pointsToWin
        winner = user

    return winner

  gameHasStarted: (game = @getCurrentGame()) ->
    return (game && game.startedAt)

  gameHasEnded: (game = @getCurrentGame()) ->
    return (game && game.endedAt)

  optionIsRegex: (input) ->
    return (_.first(input) == '/' && _.last(input) == '/')

  getOppositePlayer: (user) ->
    return if !@.isInvitedUser(user) then @.getInvitedUserByGame() else @.getAdminUserByGame()

  submitAnswer: (answer, user = Meteor.user()) ->
    game = @getCurrentGame()
    roundNumber = game.getCurrentRoundNumber()
    Games.update game._id,
      $push:
        draws:
          roundNumber: roundNumber
          userId: user._id
          userInput: answer

  getPointsByUser: (user = Meteor.user()) ->
    game = @getCurrentGame()
    currentRoundNumber = game.getCurrentRoundNumber()
    points = 0
    for roundNumber in [0..currentRoundNumber] by 1
      winner = RiddleBomb.getRoundWinner(roundNumber)
      if winner && winner._id == user._id
        points++
    return points

  activateTrackerChecks: ->
    trackerChecks.set(true)

  resetGame: ->
    game = @getCurrentGame()
    Games.update game._id,
      $set:
        draws: []
        endedAt: null
        startedAt: new Date()

  getConfig: ->
    config


Tracker.autorun ->
  if trackerChecks.get()
    Tracker.autorun ->
      if RiddleBomb.userIsInRunningGame() && RiddleBomb.getCurrentDrawTime() < 0
        console.log 'submit'
        RiddleBomb.submitAnswer('')

    Tracker.autorun ->
      if RiddleBomb.gameHasStarted() && RiddleBomb.getGameWinner() && !RiddleBomb.gameHasEnded()
        RiddleBomb.endGame()