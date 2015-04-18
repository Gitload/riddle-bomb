@Games = new Meteor.Collection('games');

getUserOptions = ->
  _.map Meteor.users.find().fetch(), (user) ->
    label: "#{user.profile.firstName} #{user.profile.lastName}"
    value: user._id

mergeAnswersWithDraws = (answers, draws, callback) ->
  for answerOptions in answers
    answerObj =
      answered: false
      title: answerOptions[0]

    for draw in draws
      if inputFitsAnswer(draw.userInput, answerOptions)
        answerObj.answered = true
        answerObj.answeredByUser = Meteor.users.findOne(draw.userId)

    callback answerObj

mergeDrawsWithStatus = (draws, answers) ->
  inputs = []
  for draw in draws
    draw.correctAnswer = false
    if inputs.indexOf(draw.userInput) > -1
      draw.isDuplicate = true
      continue
    inputs.push draw.userInput
    for answerOptions in answers
      if inputFitsAnswer(draw.userInput, answerOptions)
        draw.correctAnswer = true
  return draws

inputFitsAnswer = (input, answerOptions) ->
  fits = false
  for option in answerOptions
    if option.toLowerCase() == input.toLowerCase()
      fits = true
  return fits



Schemas.Entries = new SimpleSchema

  "userIds":
    type: [String]
    autoform:
      label: "User"
      options: getUserOptions

  "adminUserId":
    type: String
    autoform:
      label: "Admin"
      options: getUserOptions

  "questionIds":
    type: [String]
    autoform:
      label: "Question"
      options: ->
        _.map Questions.find().fetch(), (question) ->
          label: question.title
          value: question._id

  startedAt:
    type: Date
    optional: true

  endedAt:
    type: Date
    optional: true

  winnerUserId:
    type: String
    optional: true
    autoform:
      label: "Winner"
      options: getUserOptions

  "draws" :
    type: [Object]
    defaultValue: []

  "draws.$.roundNumber" :
    type: Number

  "draws.$.userId":
    type: String

  "draws.$.userInput":
    type: String

Games.helpers
  getCurrentRoundNumber: ->
    roundNumber = 0
    for draw in this.draws
      if draw.roundNumber > roundNumber
        roundNumber = draw.roundNumber
    if(@roundIsFinal(roundNumber))
      return roundNumber
    if(@roundHasFinalDraw(roundNumber))
      roundNumber++
    return roundNumber

  roundIsFinal: (roundNumber = @getCurrentRoundNumber()) ->
    return (roundNumber + 1 >= @.questionIds.length)

  getCurrentDrawNumber: ->
    @draws.length

  getQuestionByRoundNumber: (roundNumber = 0) ->
    questionId = @.questionIds[roundNumber]
    question = Questions.findOne(questionId)
    return question

  getCurrentQuestion: ->
    roundNumber = @getQuestionByRoundNumber(@getCurrentRoundNumber())

  roundHasFinalDraw: (roundNumber = @getCurrentRoundNumber())->
    drawsWithStatus = mergeDrawsWithStatus @getDrawsByRoundNumber(roundNumber), @getQuestionByRoundNumber(roundNumber).answers
    finalDraw = false
    _.each drawsWithStatus, (draw) ->
      if !draw.correctAnswer
        finalDraw = draw
    if(!finalDraw && drawsWithStatus.length == @.getQuestionByRoundNumber(roundNumber).answers.length)
      finalDraw = _.last drawsWithStatus
    return finalDraw

  getAnswersWithStatus: ->
    answersWithStatus = []
    mergeAnswersWithDraws @getCurrentQuestion().answers, @getCurrentDraws(), (answerObj) ->
      answersWithStatus.push answerObj

    return answersWithStatus

  getCurrentDraws: ->
    return @getDrawsByRoundNumber(@getCurrentRoundNumber())

  getDrawsByRoundNumber: (roundNumber = 0) ->
    return _.filter this.draws, (draw) ->
      return (draw.roundNumber == roundNumber)

Games.attachSchema(Schemas.Entries)
