facebookFriends = new ReactiveVar()

if(Meteor.isClient)
  Meteor.subscribe 'user', () ->
    facebookFriends.set FacebookCollections.getFriends('me').find {}

getUserById  = (id) ->
  return Meteor.findOne id

@RiddleBomb =

  getUsersByFacebookFriends: () ->
    facebookIds = _.map facebookFriends.get().fetch(), (doc) ->
      doc.id
    facebookIds = ["861077017290735"]
    collection = Meteor.users
    return collection.find
      "services.facebook.id": {$in: facebookIds}


  getUsedQuestionIdsByUser: (user) ->
    games = Games.find
      userIds : user._id

    questionsIds = _.map games.fetch(), (doc) ->
      doc.questionIds

    return _.flatten questionsIds


  getAvailableQuestions: (users) ->
    usedQuestionsIds = _.flatten (@getUsedQuestionIdsByUser(user) for user in users)

    console.log usedQuestionsIds
    availableQuestions = Questions.find
      "_id" : {$nin: usedQuestionsIds}

    return availableQuestions

  createNewGame: (options) ->
    users = [Meteor.user(), options.invitee];
    availableQuestions = @getAvailableQuestions users;
    questionForGame = _.shuffle availableQuestions.fetch().slice 0,6

    Games.insert
      userIds : (user._id for user in users)
      questionIds: (question._id for question in questionForGame)


