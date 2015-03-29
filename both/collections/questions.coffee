@Questions = new Meteor.Collection('questions');

Schemas.Entries = new SimpleSchema
  title:
    type:String
    max: 60

  "answers.$.options":
    type: [String]
    autoform:
      type: 'tags'

Questions.attachSchema(Schemas.Entries)