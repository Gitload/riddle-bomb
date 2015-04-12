@Games = new Meteor.Collection('games');

getUserOptions = ->
  _.map Meteor.users.find().fetch(), (user) ->
    label: "#{user.profile.firstName} #{user.profile.lastName}"
    value: user._id

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

  currentRoundNumber:
    type: Number
    autoValue: ->
      @value || 0

  currentDrawNumber:
    type: Number
    autoValue: ->
      @value || 0

  "draws.$.roundNumber" :
    type: Number

  "draws.$.userId":
    type: String

  "draws.$.userInput":
    type: String

Games.attachSchema(Schemas.Entries)