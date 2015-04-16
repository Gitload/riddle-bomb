@Questions = new Meteor.Collection('questions');

Schemas.Entries = new SimpleSchema
  title:
    type:String

  "answers":
    type: Array
    optional: true

  "answers.$":
    type: [String]
    autoform:
      type: 'tags'

Questions.attachSchema(Schemas.Entries)