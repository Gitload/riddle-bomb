facebookFriends = new ReactiveVar()

if Meteor.isClient
  if Meteor.userId()
    Meteor.subscribe 'user', () ->
      facebookFriends.set FacebookCollections.getFriends('me').find {}

getUserById  = (id) ->
  return Meteor.findOne id

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
    if(availableQuestions.count() < 2)
      Alert.error "There are no available questions!"
      return

    questionForGame = _.shuffle availableQuestions.fetch().slice 0,6

    Games.insert
      userIds : (user._id for user in users)
      adminUserId: users[0]._id
      questionIds: (question._id for question in questionForGame)

  startGame: (game) ->
    Games.update game._id,
      startedAt: new Date()
