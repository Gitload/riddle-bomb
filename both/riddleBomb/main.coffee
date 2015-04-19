facebookFriends = new ReactiveVar()

if Meteor.isClient
  if Meteor.userId()
    Meteor.subscribe 'user', () ->
      facebookFriends.set FacebookCollections.getFriends('me').find {}

getUserById  = (id) ->
  return Meteor.findOne id

currentGame = false

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
    Games.find
      userIds: user._id
      endedAt: null
      startedAt : {$not: null}

  userIsInRunningGame: (user) ->
    return (@getRunningGamesForUser(user).count() > 0)

  getCurrentGame : ->
    if Router.current().route.getName() != 'game'
      return
    if !currentGame
      gameId = Router.current().data().gameId
      currentGame = new Game gameId,
        onDrawAdded : (draw) ->
          roundNumber = draw.roundNumber
          roundWinner = RiddleBomb.getRoundWinner(roundNumber)
          if(roundWinner)
            Modals.showWinnerByRoundNumber(roundNumber)

    return currentGame.fetch()[0]

  getAdminUserByGame: (game = @getCurrentGame()) ->
    Meteor.users.findOne game.adminUserId

  getInvitedUserByGame: (game = @getCurrentGame()) ->
    invitedUserId = _.without(game.userIds, game.adminUserId)[0]
    return Meteor.users.findOne invitedUserId


  getAvailableQuestions: (users) ->
    usedQuestionsIds = _.flatten (@getUsedQuestionIdsByUser(user) for user in users)

    availableQuestions = Questions.find
      "_id" : {$nin: usedQuestionsIds}

    return availableQuestions

  createNewGame: (options) ->
    users = [Meteor.user(), options.invitee];
    availableQuestions = @getAvailableQuestions users;
    #if(availableQuestions.count() < 2)
      #Alert.error "There are no available questions!"
      #return

    questionForGame = _.shuffle availableQuestions.fetch().slice 0,6

    Games.insert
      userIds : (user._id for user in users)
      adminUserId: users[0]._id
      questionIds: (question._id for question in questionForGame)

  startGame: (game = @getCurrentGame()) ->
    Games.update game._id,
      $set:
        startedAt: new Date()

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
