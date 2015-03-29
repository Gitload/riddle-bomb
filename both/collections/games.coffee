@Games = new Meteor.Collection('games');

Schemas.Entries = new SimpleSchema
  userIds:
    type:[String]

  QuestionIds:
    type: [String]

  startedAt:
    type: Date

  endedAt:
    type: Date

  winner:
    type: String

  currentRoundNumber:
    type: Number

  currentDrawNumber:
    type: Number

  "draws.$.roundNumber" :
    type: Number

  "draws.$.userId":
    type: String

  "draws.$.userInput":
    type: String

Games.attachSchema(Schemas.Entries)