facebookFriends = new ReactiveVar()

if Meteor.isClient
  if Meteor.userId()
    Meteor.subscribe 'user', () ->
      facebookFriends.set FacebookCollections.getFriends('me').find {}

getUserById  = (id) ->
  return Meteor.findOne id

getDrawsByRoundNumber = (draws, roundNumber) ->
  return _.map draws, (draw) ->
    if(draw.roundNumber != roundNumber)
      return false
    return draw

mergeDrawsWithAnswers = (draws, answers, callback) ->
  for answerOptions in answers
    answerObj =
      answered: false

    for option, index in answerOptions
      if(index == 0)
        answerObj.title = answerOptions[0]
      for draw in draws
        if option == draw.userInput
          answerObj.answered = true
          answerObj.answeredByUser = Meteor.users.findOne(draw.userId)

    callback answerObj

@RiddleBomb =

  getUsersByFacebookFriends: () ->
    facebookIds = _.map facebookFriends.get().fetch(), (doc) ->
      doc.id
    collection = Meteor.users
    invitedUserIds = _.flatten _.map @getPendingGamesForAdmin().fetch(), (doc) ->
      doc.userIds

    return collection.find
      "services.facebook.id": {$in: facebookIds}
      "_id" : {$nin: invitedUserIds}


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
      #startedAt : {$not: null}

  getCurrentGame : ->
    if Router.current().route.getName() != 'game'
      return
    return Router.current().data()

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

  startGame: (game) ->
    Games.update game._id,
      $set:
        startedAt: new Date()

  getCurrentQuestion: ->
    currentRoundNumber = @getCurrentGame().currentRoundNumber
    questionId = @getCurrentGame().questionIds[currentRoundNumber]
    question = Questions.findOne(questionId)
    return question

  userHasTurn: (user = Meteor.user()) ->
    currentDrawNumber = @getCurrentGame().currentDrawNumber
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
    game = @getCurrentGame()
    currentQuestion = @getCurrentQuestion()
    currentRoundNumber = game.currentRoundNumber
    currentDrawNumber = game.currentDrawNumber
    answersWithStatus = []
    draws = getDrawsByRoundNumber game.draws, currentRoundNumber

    mergeDrawsWithAnswers draws, currentQuestion.answers, (answerObj) ->
      answersWithStatus.push answerObj

    return answersWithStatus


  submitAnswer: (answer, user = Meteor.user()) ->
    game = @getCurrentGame()
    Games.update game._id,
      $push:
        draws:
          roundNumber: game.currentRoundNumber
          userId: user._id
          userInput: answer
    @nextDraw()

  nextDraw: ->
    game = @getCurrentGame()
    Games.update game._id,
      $set:
        currentDrawNumber: game.currentDrawNumber + 1
